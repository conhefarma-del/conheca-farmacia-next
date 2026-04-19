function formatDate(dateStr) {
    const date = new Date(dateStr + 'T00:00:00');
    const options = { year: 'numeric', month: 'long', day: 'numeric' };
    return date.toLocaleDateString('pt-PT', options);
}

function formatDateSimple(dateStr) {
    const date = new Date(dateStr + 'T00:00:00');
    const options = { day: '2-digit', month: '2-digit', year: 'numeric' };
    return date.toLocaleDateString('pt-PT', options);
}

// Função para contar inscrições reais do Supabase
async function getInscriptionCount(eventoSlug) {
    try {
        console.log(`🔍 Contando inscrições para: ${eventoSlug}`);

        // Verificar se Supabase está disponível
        if (!window.SUPABASE_URL || !window.SUPABASE_ANON_KEY) {
            console.warn('⚠️ Supabase credentials não disponíveis');
            console.warn(`   SUPABASE_URL: ${window.SUPABASE_URL ? '✓' : '✗'}`);
            console.warn(`   SUPABASE_ANON_KEY: ${window.SUPABASE_ANON_KEY ? '✓' : '✗'}`);
            return null;
        }

        // Sintaxe correta: sem select=count(), apenas com Prefer header
        const url = `${window.SUPABASE_URL}/rest/v1/inscricoes?evento_slug=eq.${encodeURIComponent(eventoSlug)}&limit=1`;
        console.log(`🔗 URL: ${url}`);

        const response = await fetch(url, {
            headers: {
                'Authorization': `Bearer ${window.SUPABASE_ANON_KEY}`,
                'apikey': window.SUPABASE_ANON_KEY,
                'Prefer': 'count=exact'
            }
        });

        console.log(`📊 Status: ${response.status}`);
        console.log(`📝 Content-Range: ${response.headers.get('content-range')}`);

        if (!response.ok) {
            console.warn('⚠️ Erro ao contar inscrições:', response.status, response.statusText);
            return null;
        }

        const contentRange = response.headers.get('content-range');
        if (!contentRange) {
            console.warn('⚠️ Sem header content-range');
            return null;
        }

        // Format: "0-0/23" onde 23 é o total
        const count = parseInt(contentRange.split('/')[1]);
        console.log(`✅ Inscrições encontradas: ${count}`);
        return count;
    } catch (error) {
        console.error('❌ Erro ao conectar com Supabase:', error.message);
        console.error('Stack:', error.stack);
        return null;
    }
}

document.addEventListener('DOMContentLoaded', async () => {
    const params = new URLSearchParams(window.location.search);
    const eventId = params.get('id');

    const eventNotFound = document.getElementById('event-not-found');
    const similarEventsSection = document.getElementById('similar-events-section');

    if (!eventId) {
        eventNotFound.classList.remove('hidden');
        return;
    }

    try {
        console.log('Carregando catálogo de eventos...');
        const response = await fetch('content/events-catalog.json');

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        console.log('Catálogo carregado:', data);

        // Find event by ID
        const event = data.events.find(e => e.id == eventId);

        if (!event) {
            console.error(`Evento com ID ${eventId} não encontrado`);
            eventNotFound.classList.remove('hidden');
            return;
        }

        console.log('Evento encontrado:', event);

        // Calculate event status
        const today = new Date();
        todayFormatted = today.toISOString().split('T')[0];
        const isUpcoming = event.date >= todayFormatted;
        const eventStatus = isUpcoming ? 'upcoming' : 'past';

        // Get category color
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

        const categoryColor = getCategoryColor(event.category);

        // Populate Hero Section
        const categoryBadge = document.getElementById('event-category');
        categoryBadge.textContent = event.categoryLabel;
        categoryBadge.style.backgroundColor = categoryColor + '20';
        categoryBadge.style.color = categoryColor;

        document.getElementById('event-title').textContent = event.title;

        const featuredImage = document.getElementById('event-featured-image');
        featuredImage.src = event.image;
        featuredImage.alt = event.title;

        // Event Meta Bar
        const typeLabel = event.type === 'online' ? 'Online' : 'Presencial';
        document.getElementById('event-type-meta').textContent = typeLabel;
        document.getElementById('event-type-meta').style.backgroundColor = categoryColor + '20';
        document.getElementById('event-type-meta').style.color = categoryColor;

        document.getElementById('event-date-meta').textContent = formatDate(event.date);
        document.getElementById('event-location-meta').textContent = event.location;
        document.getElementById('event-time-meta').textContent = `${event.time} — ${event.endTime}`;

        // Populate Content Section
        document.getElementById('event-description').textContent = event.excerpt;

        // Event Details
        document.getElementById('event-type-detail').textContent = typeLabel;
        document.getElementById('event-date-detail').textContent = formatDate(event.date);
        document.getElementById('event-time-detail').textContent = `${event.time} — ${event.endTime} (${calculateDuration(event.time, event.endTime)})`;
        document.getElementById('event-location-detail').textContent = event.location;

        // SINCRONIZAR COM SUPABASE: Contar inscrições reais
        let inscriptionCount = event.registered; // Valor padrão do JSON
        console.log(`📊 Valor padrão (JSON): ${inscriptionCount}`);

        const realCount = await getInscriptionCount(event.slug);

        if (realCount !== null && realCount !== undefined) {
            inscriptionCount = realCount;
            console.log(`✅ Usando contagem real do Supabase: ${inscriptionCount}`);
        } else {
            console.log(`⚠️ Falha na query Supabase, usando JSON: ${inscriptionCount}`);
        }

        // Capacity Information - AGORA SINCRONIZADO
        const spotsLeft = event.capacity - inscriptionCount;
        const capacityPercent = Math.round((inscriptionCount / event.capacity) * 100);

        console.log(`📈 Capacidade: ${event.capacity}, Inscrições: ${inscriptionCount}, Vagas: ${spotsLeft}, Percentual: ${capacityPercent}%`);

        const capacityFilled = document.getElementById('event-capacity-filled');
        capacityFilled.style.width = capacityPercent + '%';
        capacityFilled.style.backgroundColor = capacityPercent >= 100 ? '#dc2626' : categoryColor;

        const capacityText = document.getElementById('event-capacity-text');
        if (spotsLeft > 0) {
            capacityText.textContent = `${spotsLeft} vagas disponíveis de ${event.capacity}`;
            capacityText.style.color = '#1f2937'; // cor normal
        } else {
            capacityText.textContent = 'Evento completo - Sem vagas disponíveis';
            capacityText.style.color = '#dc2626';
        }

        // Registration Button
        const registrationBtn = document.getElementById('event-registration-btn');
        registrationBtn.setAttribute('data-event-slug', event.slug);

        if (eventStatus === 'past') {
            registrationBtn.textContent = 'Ver Gravação';
            registrationBtn.classList.remove('btn-primary');
            registrationBtn.classList.add('btn-secondary');
            registrationBtn.disabled = true;
        } else if (spotsLeft <= 0) {
            // BLOQUEAR SE CAPACIDADE ATINGIDA
            registrationBtn.textContent = 'Evento Completo';
            registrationBtn.disabled = true;
            registrationBtn.classList.add('btn-disabled');
            console.log('🚫 Inscrições fechadas - Capacidade máxima atingida');
        } else {
            registrationBtn.textContent = 'Inscrever-me';
            registrationBtn.disabled = false;
        }

        // Host/Presenter Card
        const hostInitials = event.host.name
            .split(' ')
            .map(word => word[0])
            .join('')
            .toUpperCase()
            .slice(0, 2);

        const hostAvatar = document.getElementById('host-avatar');
        hostAvatar.textContent = hostInitials;
        hostAvatar.style.backgroundColor = categoryColor;

        document.getElementById('host-role').textContent = event.host.role;
        document.getElementById('host-name').textContent = event.host.name;
        document.getElementById('host-organization').textContent = event.host.organization;

        // Update Page Title
        document.title = `${event.title} - Conheça Farmácia`;

        // Similar Events
        const similarEvents = getSimilarEvents(data.events, event);
        if (similarEvents.length >= 2) {
            similarEventsSection.classList.remove('hidden');
            renderSimilarEvents(similarEvents, data.events);
        } else {
            similarEventsSection.classList.add('hidden');
        }

    } catch (error) {
        console.error('Erro ao carregar detalhe do evento:', error);
        eventNotFound.classList.remove('hidden');
    }

    function calculateDuration(startTime, endTime) {
        const [startHour, startMin] = startTime.split(':').map(Number);
        const [endHour, endMin] = endTime.split(':').map(Number);

        const startTotalMin = startHour * 60 + startMin;
        const endTotalMin = endHour * 60 + endMin;

        const durationMin = endTotalMin - startTotalMin;
        const hours = Math.floor(durationMin / 60);
        const minutes = durationMin % 60;

        if (hours > 0 && minutes > 0) {
            return `${hours}h${minutes}min`;
        } else if (hours > 0) {
            return `${hours}h`;
        } else {
            return `${minutes}min`;
        }
    }

    function getSimilarEvents(allEvents, currentEvent) {
        return allEvents
            .filter(e =>
                e.category === currentEvent.category &&
                e.id !== currentEvent.id
            )
            .slice(0, 3);
    }

    function renderSimilarEvents(similarEvents, allEvents) {
        const grid = document.getElementById('similar-events-grid');
        grid.innerHTML = '';

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

        function calculateStatus(eventDate) {
            const today = new Date().toISOString().split('T')[0];
            return eventDate >= today ? 'upcoming' : 'past';
        }

        similarEvents.forEach(event => {
            const categoryColor = getCategoryColor(event.category);
            const eventDate = formatDate(event.date);
            const dateObj = new Date(event.date + 'T00:00:00');
            const day = String(dateObj.getDate()).padStart(2, '0');
            const month = ['JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN', 'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'][dateObj.getMonth()];

            const card = document.createElement('article');
            card.className = 'event-card';

            const spotsLeft = event.capacity - event.registered;

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
                        <div class="event-meta-item">
                            <span>Evento completo</span>
                        </div>
                        `}
                    </div>

                    <a href="evento.html?id=${event.id}" class="event-card-cta">
                        Mais Informações
                    </a>
                </div>
            `;
            grid.appendChild(card);
        });
    }
});
