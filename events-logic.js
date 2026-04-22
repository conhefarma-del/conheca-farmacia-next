let events = [];
let currentStatus = 'upcoming';
let currentCategory = 'all';

document.addEventListener('DOMContentLoaded', () => {
    const grid = document.getElementById('events-grid');
    const noResults = document.getElementById('no-results');
    const temporalBtns = document.querySelectorAll('.temporal-btn');
    const categoryBtns = document.querySelectorAll('.filter-btn');
    const newsletterForm = document.getElementById('newsletter-form');

    function getTodayDate() {
        const today = new Date();
        return today.toISOString().split('T')[0];
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
            congresso: '#002a32',
            live: '#006171',
            webinar: '#7c3aed'
        };
        return colors[category] || '#00493a';
    }

    function renderEvents() {
        console.log(`Renderizando eventos. Status: ${currentStatus}, Categoria: ${currentCategory}`);

        const filtered = events.filter(event => {
            const matchesStatus = event.status === currentStatus;
            const matchesCategory = currentCategory === 'all' || event.category === currentCategory;
            return matchesStatus && matchesCategory;
        });

        console.log(`Eventos encontrados: ${filtered.length}`);

        grid.innerHTML = '';

        if (filtered.length === 0) {
            noResults.classList.remove('hidden');
        } else {
            noResults.classList.add('hidden');

            filtered.forEach(event => {
                const card = document.createElement('article');
                card.className = 'event-card';

                const categoryColor = getCategoryColor(event.category);
                const eventDate = formatDate(event.date);
                const dateObj = new Date(event.date + 'T00:00:00');
                const day = String(dateObj.getDate()).padStart(2, '0');
                const month = ['JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN', 'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'][dateObj.getMonth()];

                // USAR event.registered do JSON como padrão (será atualizado por Supabase em tempo real)
                const spotsLeft = event.capacity - event.registered;
                const isCapacityFull = spotsLeft <= 0;

                card.innerHTML = `
                    <div class="event-card-header">
                        <div class="event-card-date-box" style="background-color: ${categoryColor}">
                            <div class="day">${day}</div>
                            <div class="month">${month}</div>
                        </div>
                        <img src="${event.image}" alt="${event.title}" class="event-card-image">
                    </div>
                    <div class="event-card-content">
                        <div class="event-card-meta-top">
                            <span class="event-badge" style="background-color: ${categoryColor}20; color: ${categoryColor}">
                                ${event.categoryLabel}
                            </span>
                            <span class="event-type-badge">${event.type === 'online' ? 'Online' : 'Presencial'}</span>
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
                            <div class="event-meta-item event-meta-full" style="color: #dc2626;">
                                <span>Evento completo</span>
                            </div>
                            `}
                        </div>

                        <div class="event-card-actions">
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
            });
        }
    }

    // Temporal Filter (Upcoming/Past Toggle)
    temporalBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            temporalBtns.forEach(b => b.classList.remove('temporal-btn-active'));
            btn.classList.add('temporal-btn-active');
            currentStatus = btn.dataset.status;
            renderEvents();
        });
    });

    // Category Filter
    categoryBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            categoryBtns.forEach(b => b.classList.remove('filter-btn-active'));
            btn.classList.add('filter-btn-active');
            currentCategory = btn.dataset.category;
            renderEvents();
        });
    });

    // Newsletter Form
    newsletterForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const email = document.getElementById('newsletter-email').value;
        console.log('Newsletter signup:', email);
        ErrorHandler.handle(new Error('Newsletter signup'), 'TOAST', 'Obrigado por se inscrever! Verificaremos em breve');
        newsletterForm.reset();
    });

    // Load events
    async function loadEvents() {
        try {
            console.log('Carregando catálogo de eventos...');
            const response = await fetch('content/events-catalog.json');

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const data = await response.json();
            console.log('Catálogo carregado:', data);

            // Calculate status based on date
            events = data.events.map(event => ({
                ...event,
                status: calculateStatus(event.date)
            }));

            console.log('Events com status calculado:', events.length);
            renderEvents();
        } catch (error) {
            console.error('Erro ao carregar catálogo de eventos:', error);
            ErrorHandler.handle(error, 'TOAST', 'Não foi possível carregar os eventos neste momento.');
        }
    }

    loadEvents();
});
