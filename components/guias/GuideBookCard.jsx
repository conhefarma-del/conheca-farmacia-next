/**
 * Card de livro. `coverUrl` é validado server-side (https:// ou relativo).
 * Links externos abrem em nova aba com rel="noopener noreferrer".
 */
export default function GuideBookCard({ book }) {
  return (
    <div className="guide-book-card">
      {book.coverUrl && (
        <img
          src={book.coverUrl}
          alt={book.title}
          className="guide-book-cover"
          loading="lazy"
        />
      )}
      <div className="guide-book-info">
        <h4 className="guide-book-title">{book.title}</h4>
        <p className="guide-book-meta">
          {book.author}
          {book.edition ? ` · ${book.edition}` : ''}
          {book.year ? ` · ${book.year}` : ''}
        </p>
        {book.teamParagraph && <p className="guide-book-paragraph">{book.teamParagraph}</p>}
        {book.links?.length > 0 && (
          <div className="guide-book-links">
            {book.links.map((link, i) => (
              <a
                key={i}
                href={link.url}
                target="_blank"
                rel="noopener noreferrer"
                className="guide-book-link"
              >
                {link.label}
              </a>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}
