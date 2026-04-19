// Format date to Portuguese
function formatDate(dateStr) {
    const date = new Date(dateStr);
    const options = { year: 'numeric', month: 'long', day: 'numeric' };
    return date.toLocaleDateString('pt-PT', options);
}

// Load and render article
async function loadArticle() {
    const params = new URLSearchParams(window.location.search);
    const articleId = params.get('id');

    if (!articleId) {
        document.body.innerHTML = '<div class="container-center py-20 text-center"><h1>Artigo não encontrado</h1></div>';
        return;
    }

    try {
        // Fetch catalog
        console.log('Fetching catalog...');
        const catalogResponse = await fetch('content/articles-catalog.json');

        if (!catalogResponse.ok) {
            throw new Error(`Erro ao carregar catálogo: ${catalogResponse.status}`);
        }

        const catalog = await catalogResponse.json();
        console.log('Catálogo carregado:', catalog);

        // Find article in catalog
        const article = catalog.articles.find(a => a.id == articleId);

        if (!article) {
            console.error('Artigo não encontrado. ID:', articleId);
            document.body.innerHTML = '<div class="container-center py-20 text-center"><h1>Artigo não encontrado</h1></div>';
            return;
        }

        console.log('Artigo encontrado:', article);

        // Convert markdown to HTML (with sanitization)
        const rawHtmlContent = marked.parse(article.content);
        // Sanitize HTML to prevent XSS injection
        const htmlContent = DOMPurify.sanitize(rawHtmlContent, {
            ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'p', 'br', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'ul', 'ol', 'li', 'blockquote', 'code', 'pre', 'a', 'img', 'table', 'thead', 'tbody', 'tr', 'th', 'td'],
            ALLOWED_ATTR: ['href', 'src', 'alt', 'title', 'target']
        });

        // Populate hero section
        const categoryClass = `tag-${article.category}`;
        document.getElementById('article-category').className = `article-tag ${categoryClass}`;
        document.getElementById('article-category').textContent = article.categoryLabel;
        document.getElementById('article-title').textContent = article.title;
        document.getElementById('article-featured-image').src = article.image;
        document.getElementById('article-featured-image').alt = article.title;

        // Populate meta bar
        document.getElementById('article-author-avatar').textContent = article.author.avatar;
        document.getElementById('article-author-avatar').style.backgroundColor = article.author.avatarBg;
        document.getElementById('article-author-name').textContent = article.author.name;
        document.getElementById('article-author-role').textContent = article.author.role;
        document.getElementById('article-date').textContent = formatDate(article.date);
        document.getElementById('article-readtime').textContent = `${article.readTime} min leitura`;

        // Populate article body
        document.getElementById('article-body').innerHTML = htmlContent;

        // Populate sidebar author card
        document.getElementById('sidebar-author-avatar').textContent = article.author.avatar;
        document.getElementById('sidebar-author-avatar').style.backgroundColor = article.author.avatarBg;
        document.getElementById('sidebar-author-role').textContent = article.author.role;
        document.getElementById('sidebar-author-name').textContent = article.author.name;
        document.getElementById('sidebar-author-bio').textContent = article.author.bio;

        // Load related articles (same category, exclude current)
        const relatedArticles = catalog.articles.filter(
            a => a.category === article.category && a.id !== article.id
        ).slice(0, 3);

        const relatedSection = document.querySelector('.article-related-section');
        const relatedGrid = document.getElementById('related-articles-grid');

        // Only show related section if there are 2 or more related articles
        if (relatedArticles.length < 2) {
            relatedSection.style.display = 'none';
        } else {
            relatedSection.style.display = 'block';
            relatedGrid.innerHTML = '';

            relatedArticles.forEach(relArticle => {
                const card = document.createElement('article');
                card.className = 'article-card';
                card.innerHTML = `
                    <img src="${relArticle.image}" alt="${relArticle.title}" class="article-card-img">
                    <div class="article-card-content">
                        <span class="article-tag tag-${relArticle.category}">${relArticle.categoryLabel}</span>
                        <h3 class="article-card-title">${relArticle.title}</h3>
                        <p class="article-card-excerpt">${relArticle.excerpt}</p>
                        <a href="artigo.html?id=${relArticle.id}" class="article-card-link">Ler mais <span>→</span></a>
                    </div>
                `;
                relatedGrid.appendChild(card);
            });
        }

        // Update page title
        document.title = `${article.title} - Conheça Farmácia`;

    } catch (error) {
        console.error('Erro ao carregar artigo:', error);
        // SECURITY: Não expor error.message ao utilizador (Information Disclosure)
        document.body.innerHTML = `<div class="container-center py-20 text-center"><h1>Desculpe, artigo não disponível</h1><p>Não conseguimos carregar este artigo neste momento. Por favor, tente novamente mais tarde ou contacte o suporte.</p></div>`;
    }
}

// Load article on page load
document.addEventListener('DOMContentLoaded', loadArticle);

