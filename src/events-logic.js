import eventsData from './content/events-catalog.json';
import { SUPABASE_URL, SUPABASE_ANON_KEY, supabaseClient } from './config.js';

let events = [];
let currentStatus = 'upcoming';
let currentCategory = 'all';

// ==========================================
// DIAGNÓSTICO: Função exposta para debugging no console
// ==========================================
window.debugInscriptions = async function(slug) {
 const s = slug || '001-farmacologia-clinica';
 console.log('🔍 Debug: Contando inscrições para:', s);

 const { data, error, count } = await supabaseClient
 .from('inscricoes')
 .select('*', { count: 'exact', head: true })
 .eq('evento_slug', s);

 console.log('📊 Resultado:', { data, error, count });
 console.log('📝 SQL: SELECT * FROM inscricoes WHERE evento_slug = ?', s);

 if (error) {
 console.error('❌ Erro:', error);
 } else {
 console.log(`✅ ${count} inscrições encontradas`);
 }
 return { data, error, count };
};

console.log('💡 DICA: Execute debugInscriptions("001-farmacologia-clinica") no console para debug');

// Função para contar inscrições reais do Supabase
async function getInscriptionCount(eventoSlug) {
 try {
 console.log(`🔍 [events-logic] Contando inscrições para: "${eventoSlug}"`);

 if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
 console.warn('⚠️ Supabase credentials não disponíveis');
 return null;
 }

 // Usar cliente Supabase para melhor fiabilidade
 const { data, error, count } = await supabaseClient
 .from('inscricoes')
 .select('*', { count: 'exact', head: true })
 .eq('evento_slug', eventoSlug);

 if (error) {
 console.error(`❌ [events-logic] Erro Supabase:`, error.message);
 console.error('Código:', error.code);
 console.error('Detalhes:', error.details);
 return null;
 }

 console.log(`✅ [events-logic] Inscrições encontradas: ${count}`);
 return count || 0;
 } catch (error) {
 console.error('❌ [events-logic] Erro geral:', error.message);
 return null;
 }
}

document.addEventListener('DOMContentLoaded', async () => {
 const grid = document.getElementById('events-grid');
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
 workshop: '#ff6c23',
 palestra: '#0a844f',
 congresso: '#002a32'
 };
 return colors[category] || '#00493a';
 }

 async function renderEvents() {
 const filtered = events.filter(event => {
 const matchesStatus = event.status === currentStatus;
 const matchesCategory = currentCategory === 'all' || event.category === currentCategory;
 return matchesStatus && matchesCategory;
 });

 if (!grid) return;
 grid.innerHTML = '';

 if (filtered.length === 0) {
 noResults?.classList.remove('hidden');
 } else {
 noResults?.classList.add('hidden');

 for (const event of filtered) {
 const card = document.createElement('article');
 card.className = 'event-card';

 const categoryColor = getCategoryColor(event.category);
 const dateObj = new Date(event.date + 'T00:00:00');
 const day = String(dateObj.getDate()).padStart(2, '0');
 const month = ['JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN', 'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'][dateObj.getMonth()];

 let inscriptionCount = event.registered;
 const realCount = await getInscriptionCount(event.slug);
 if (realCount !== null) inscriptionCount = realCount;

 const spotsLeft = event.capacity - inscriptionCount;
 const isCapacityFull = spotsLeft <= 0;

 card.innerHTML = `
<div class="event-card-header relative">
 <div class="event-card-date-box" style="background-color: ${categoryColor}">
 <div class="day">${day}</div>
 <div class="month">${month}</div>
 </div>
 <img src="${event.image}" alt="${event.title}" class="event-card-image" loading="lazy" decoding="async">
</div>

<div class="event-card-content">
 <div class="flex flex-row flex-wrap items-center gap-2 mb-4">
 <span class="inline-block text-[10px] font-bold px-2 py-1 rounded uppercase tracking-wider"
 style="background-color: ${categoryColor}20; color: ${categoryColor}; border: 1px solid ${categoryColor}40">
 ${event.categoryLabel}
 </span>
 <span class="inline-block text-[10px] font-bold px-2 py-1 rounded uppercase tracking-wider bg-slate-100 text-slate-600 border border-slate-200">
 ${event.type === 'online' ? 'Online' : 'Presencial'}
 </span>
 </div>

 <h3 class="event-card-title">${event.title}</h3>
 <p class="event-card-excerpt">${event.excerpt}</p>

 <div class="event-card-meta">
 <div class="event-meta-item">
 <span>${event.time} — ${event.endTime}</span>
 </div>
 <div class="event-meta-item">
 <span>${event.location}</span>
 </div>
 ${spotsLeft > 0 ? `
 <div class="event-meta-item">
 <span>${spotsLeft} vagas disponíveis</span>
 </div>
 ` : `
 <div class="event-meta-item" style="color: #dc2626; font-weight: 600;">
 <span>Evento completo</span>
 </div>
 `}
 </div>

 <div class="event-card-actions mt-auto">
 <a href="evento.html?id=${event.id}" class="btn btn-secondary btn-small">
 Mais Informações
 </a>
 <button data-event-slug="${event.slug}" class="btn btn-primary btn-small btn-inscrever" ${(event.status === 'past' || isCapacityFull) ? 'disabled' : ''}>
 ${isCapacityFull ? 'Completo' : (event.status === 'upcoming' ? 'Inscrever-me' : 'Ver Gravação')}
 </button>
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
 await renderEvents();
 });
 });

 categoryBtns.forEach(btn => {
 btn.addEventListener('click', async () => {
 categoryBtns.forEach(b => b.classList.remove('filter-btn-active'));
 btn.classList.add('filter-btn-active');
 currentCategory = btn.dataset.category;
 await renderEvents();
 });
 });

 if (newsletterForm) {
 newsletterForm.addEventListener('submit', (e) => {
 e.preventDefault();
 newsletterForm.reset();
 alert('Obrigado por se inscrever!');
 });
 }

 // ==========================================
 // REFRESH ON FOCUS: Atualizar lista ao retornar à página
 // ==========================================
 window.addEventListener('focus', async () => {
 console.log('👁️ Janela em foco, atualizando lista de eventos...');
 await renderEvents();
 });

 // Verificar se há parâmetro refresh=true na URL
 const urlParams = new URLSearchParams(window.location.search);
 if (urlParams.get('refresh') === 'true') {
 console.log('🔄 Parâmetro refresh=true detetado, atualizando...');
 await renderEvents();
 // Remover apenas o parâmetro refresh
const newParams = new URLSearchParams(window.location.search);
newParams.delete('refresh');
const newUrl = window.location.pathname + (newParams.toString() ? '?' + newParams.toString() : '');
window.history.replaceState({}, '', newUrl);
 }

 // Inicialização
 events = eventsData.events.map(event => ({
 ...event,
 status: calculateStatus(event.date)
 }));

 await renderEvents();
});
