import livesData from './content/lives-catalog.json';

let lives = [];
let currentStatus = 'upcoming';
let currentCategory = 'all';

document.addEventListener('DOMContentLoaded', async () => {
 const grid = document.getElementById('lives-grid');
 const noResults = document.getElementById('no-results');
 const temporalBtns = document.querySelectorAll('.temporal-btn');
 const categoryBtns = document.querySelectorAll('.filter-btn');
 const newsletterForm = document.getElementById('newsletter-form');

 function getTodayDate() {
  return new Date().toISOString().split('T')[0];
 }

 function calculateStatus(eventDate) {
  const today = getTodayDate();
  return eventDate >= today ? 'upcoming' : 'past';
 }

 function formatDate(dateStr) {
  const date = new Date(dateStr + 'T00:00:00');
  const options = { day: 'numeric', month: 'short', year: 'numeric' };
  return date.toLocaleDateString('pt-PT', options).toUpperCase();
 }

 function getCategoryColor(category) {
  const colors = {
   live: '#006171',
   webinar: '#7c3aed'
  };
  return colors[category] || '#00493a';
 }

 async function renderLives() {
  const filtered = lives.filter(live => {
   const matchesStatus = live.status === currentStatus;
   const matchesCategory = currentCategory === 'all' || live.categoria === currentCategory;
   return matchesStatus && matchesCategory;
  });

  if (!grid) return;
  grid.innerHTML = '';

  if (filtered.length === 0) {
   noResults?.classList.remove('hidden');
  } else {
   noResults?.classList.add('hidden');

   for (const live of filtered) {
    const card = document.createElement('article');
    card.className = 'event-card';

    const categoryColor = getCategoryColor(live.categoria);
    const dateObj = new Date(live.data + 'T00:00:00');
    const day = String(dateObj.getDate()).padStart(2, '0');
    const month = ['JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN', 'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'][dateObj.getMonth()];

    card.innerHTML = `
<div class="event-card-header relative">
 <div class="event-card-date-box" style="background-color: ${categoryColor}">
  <div class="day">${day}</div>
  <div class="month">${month}</div>
 </div>
 <img src="${live.imagem}" alt="${live.titulo}" class="event-card-image">
</div>

<div class="event-card-content">
 <div class="flex flex-row flex-wrap items-center gap-2 mb-4">
  <span class="inline-block text-[10px] font-bold px-2 py-1 rounded uppercase tracking-wider"
  style="background-color: ${categoryColor}20; color: ${categoryColor}; border: 1px solid ${categoryColor}40">
  ${live.categoriaLabel}
  </span>
  <span class="inline-block text-[10px] font-bold px-2 py-1 rounded uppercase tracking-wider bg-slate-100 text-slate-600 border border-slate-200">
  ${live.plataforma}
  </span>
 </div>

 <h3 class="event-card-title">${live.titulo}</h3>
 <p class="event-card-excerpt">${live.resumo}</p>

 <div class="event-card-meta">
  <div class="event-meta-item">
   <span>${live.hora}</span>
  </div>
  <div class="event-meta-item">
   <span>${live.plataforma}</span>
  </div>
 </div>

 <div class="event-card-actions mt-auto">
  <a href="lives.html?id=${live.slug}" class="btn btn-secondary btn-small">
   Mais Informações
  </a>
  <a href="${live.link_acesso}" target="_blank" rel="noopener noreferrer" class="btn btn-primary btn-small" style="background-color: ${categoryColor}; border-color: ${categoryColor}">
   ${live.status === 'upcoming' ? 'Aceder Live' : 'Ver Gravação'}
  </a>
 </div>
</div>
`;
    grid.appendChild(card);
   }
  }
 }

 temporalBtns.forEach(btn => {
  btn.addEventListener('click', async () => {
   temporalBtns.forEach(b => b.classList.remove('temporal-btn-active'));
   btn.classList.add('temporal-btn-active');
   currentStatus = btn.dataset.status;
   await renderLives();
  });
 });

 categoryBtns.forEach(btn => {
  btn.addEventListener('click', async () => {
   categoryBtns.forEach(b => b.classList.remove('filter-btn-active'));
   btn.classList.add('filter-btn-active');
   currentCategory = btn.dataset.category;
   await renderLives();
  });
 });

 if (newsletterForm) {
  newsletterForm.addEventListener('submit', (e) => {
   e.preventDefault();
   newsletterForm.reset();
   alert('Obrigado por se inscrever!');
  });
 }

 // Refresh on focus
 window.addEventListener('focus', async () => {
  console.log('👁️ Janela em foco, atualizando lista de lives...');
  await renderLives();
 });

 // Inicialização
 lives = livesData.events.map(live => ({
  ...live,
  status: calculateStatus(live.data)
 }));

 await renderLives();
});
