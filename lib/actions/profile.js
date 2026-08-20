"use server";

import { createClient } from "@/lib/supabase/server";

/**
 * Fetch aggregated quiz + flashcard stats for the current user.
 * RLS ensures each user only sees their own data.
 */
export async function getUserStats() {
  const supabase = await createClient();
  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser();

  if (authError || !user) return null;

  // ---- Quiz stats ----
  const { data: quizRows } = await supabase
    .from("quiz_attempts")
    .select("total, correct, mode, question_source, created_at, finished_at")
    .eq("user_id", user.id)
    .order("created_at", { ascending: false });

  const quizzes = quizRows || [];
  const totalQuizzes = quizzes.length;
  const totalQuizQuestions = quizzes.reduce((s, q) => s + (q.total || 0), 0);
  const totalQuizCorrect = quizzes.reduce((s, q) => s + (q.correct || 0), 0);
  const quizAccuracy =
    totalQuizQuestions > 0
      ? Math.round((totalQuizCorrect / totalQuizQuestions) * 100)
      : 0;

  // Best streak across all quizzes (max consecutive correct answers in a single session)
  const bestQuizStreak = quizzes.reduce((best, q) => {
    if (!q.details || !Array.isArray(q.details)) return best;
    let streak = 0;
    let maxStreak = 0;
    for (const d of q.details) {
      if (d.correct) {
        streak++;
        maxStreak = Math.max(maxStreak, streak);
      } else {
        streak = 0;
      }
    }
    return Math.max(best, maxStreak);
  }, 0);

  // Sessions by mode
  const sessionsByMode = quizzes.reduce((acc, q) => {
    acc[q.mode] = (acc[q.mode] || 0) + 1;
    return acc;
  }, {});

  // Sessions by source
  const sessionsBySource = quizzes.reduce((acc, q) => {
    acc[q.question_source] = (acc[q.question_source] || 0) + 1;
    return acc;
  }, {});

  // Last quiz date
  const lastQuizAt = quizzes.length > 0 ? quizzes[0].created_at : null;

  // ---- Flashcard stats ----
  const { data: reviewRows } = await supabase
    .from("flashcard_reviews")
    .select("card_id, review_count, ease, interval_days, due_at, last_grade, repetitions, lapses")
    .eq("user_id", user.id);

  const reviews = reviewRows || [];
  const totalFlashcardsStudied = reviews.length;
  const totalReviews = reviews.reduce((s, r) => s + (r.review_count || 0), 0);
  const cardsDue = reviews.filter(
    (r) => r.due_at && new Date(r.due_at) <= new Date()
  ).length;
  const totalLapses = reviews.reduce((s, r) => s + (r.lapses || 0), 0);

  // Average ease factor
  const avgEase =
    reviews.length > 0
      ? (reviews.reduce((s, r) => s + (r.ease || 2.5), 0) / reviews.length).toFixed(2)
      : "2.5";

  // Average interval
  const avgInterval =
    reviews.length > 0
      ? Math.round(
          reviews.reduce((s, r) => s + (r.interval_days || 0), 0) / reviews.length
        )
      : 0;

  // Mastery distribution (cards by ease factor)
  const mastery = {
    new: reviews.filter((r) => r.repetitions === 0).length,
    learning: reviews.filter((r) => r.repetitions > 0 && r.repetitions < 3).length,
    young: reviews.filter((r) => r.repetitions >= 3 && r.ease >= 2.5).length,
    mature: reviews.filter((r) => r.repetitions >= 3 && r.ease < 2.5).length,
  };

  // ---- Competition stats ----
  const { count: competitionCount } = await supabase
    .from("competition_sessions")
    .select("id", { count: "exact", head: true })
    .eq("user_id", user.id);

  const { data: compRows } = await supabase
    .from("competition_sessions")
    .select(
      "total_score, correct_count, total_answered, max_streak, finished_at, " +
      "school_id, class_id, schools(name, location), classes(name, grade)"
    )
    .eq("user_id", user.id)
    .not("finished_at", "is", null)
    .order("total_score", { ascending: false })
    .limit(1);

  const bestCompetition = compRows?.[0] || null;

  // Resolve school/class from the user's competition sessions (most recent)
  let schoolName = null;
  let className = null;
  if (bestCompetition?.schools) {
    schoolName = bestCompetition.schools.name;
  } else if (bestCompetition?.school_id) {
    // Fallback: fetch directly
    const { data: sch } = await supabase
      .from("schools")
      .select("name")
      .eq("id", bestCompetition.school_id)
      .single();
    schoolName = sch?.name || null;
  }
  if (bestCompetition?.classes) {
    const grade = bestCompetition.classes.grade;
    const clsName = bestCompetition.classes.name;
    className = grade ? `${grade} ${clsName}` : clsName;
  } else if (bestCompetition?.class_id) {
    const { data: cls } = await supabase
      .from("classes")
      .select("name, grade")
      .eq("id", bestCompetition.class_id)
      .single();
    if (cls) className = cls.grade ? `${cls.grade} ${cls.name}` : cls.name;
  }

  // If no school from competitions, check user_metadata
  if (!schoolName) {
    schoolName = user.user_metadata?.school || null;
  }
  if (!className) {
    className = user.user_metadata?.class_name || null;
  }

  return {
    quiz: {
      totalQuizzes,
      totalQuizQuestions,
      totalQuizCorrect,
      quizAccuracy,
      bestQuizStreak,
      sessionsByMode,
      sessionsBySource,
      lastQuizAt,
    },
    flashcards: {
      totalFlashcardsStudied,
      totalReviews,
      cardsDue,
      totalLapses,
      avgEase: Number(avgEase),
      avgInterval,
      mastery,
    },
    competitions: {
      totalSessions: competitionCount || 0,
      bestScore: bestCompetition?.total_score || 0,
      bestAccuracy:
        bestCompetition?.total_answered > 0
          ? Math.round(
              (bestCompetition.correct_count / bestCompetition.total_answered) * 100
            )
          : 0,
      bestStreak: bestCompetition?.max_streak || 0,
      schoolName,
      className,
    },
  };
}
