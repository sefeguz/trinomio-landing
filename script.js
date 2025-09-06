// ==========================================
// TRINOMIO - JavaScript Interactivo
// ==========================================

// Inicializar AOS (Animate On Scroll)
document.addEventListener('DOMContentLoaded', function() {
    // Inicializar animaciones AOS
    AOS.init({
        duration: 800,
        easing: 'ease-out',
        once: true,
        offset: 100,
        disable: 'mobile'
    });

    // ==========================================
    // Navegación Responsive
    // ==========================================
    const navToggle = document.querySelector('.nav-toggle');
    const navMenu = document.querySelector('.nav-menu');
    const navLinks = document.querySelectorAll('.nav-menu a');

    // Toggle del menú móvil
    navToggle.addEventListener('click', function() {
        navMenu.classList.toggle('active');
        
        // Animación del botón hamburguesa
        const spans = this.querySelectorAll('span');
        if (navMenu.classList.contains('active')) {
            spans[0].style.transform = 'rotate(45deg) translateY(8px)';
            spans[1].style.opacity = '0';
            spans[2].style.transform = 'rotate(-45deg) translateY(-8px)';
        } else {
            spans[0].style.transform = 'none';
            spans[1].style.opacity = '1';
            spans[2].style.transform = 'none';
        }
    });

    // Cerrar menú al hacer click en un enlace
    navLinks.forEach(link => {
        link.addEventListener('click', function() {
            navMenu.classList.remove('active');
            const spans = navToggle.querySelectorAll('span');
            spans[0].style.transform = 'none';
            spans[1].style.opacity = '1';
            spans[2].style.transform = 'none';
        });
    });

    // ==========================================
    // Navbar con efecto al hacer scroll
    // ==========================================
    const navbar = document.querySelector('.navbar');
    let lastScroll = 0;

    window.addEventListener('scroll', function() {
        const currentScroll = window.pageYOffset;

        // Añadir sombra cuando se hace scroll
        if (currentScroll > 50) {
            navbar.style.boxShadow = '0 4px 30px rgba(0,0,0,0.1)';
            navbar.style.padding = '0.8rem 0';
        } else {
            navbar.style.boxShadow = '0 2px 20px rgba(0,0,0,0.05)';
            navbar.style.padding = '1rem 0';
        }

        // Ocultar/mostrar navbar según dirección del scroll
        if (currentScroll > lastScroll && currentScroll > 200) {
            navbar.style.transform = 'translateY(-100%)';
        } else {
            navbar.style.transform = 'translateY(0)';
        }

        lastScroll = currentScroll;
    });

    // ==========================================
    // Smooth Scroll mejorado para enlaces internos
    // ==========================================
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            
            if (target) {
                const headerOffset = 80;
                const elementPosition = target.getBoundingClientRect().top;
                const offsetPosition = elementPosition + window.pageYOffset - headerOffset;

                window.scrollTo({
                    top: offsetPosition,
                    behavior: 'smooth'
                });
            }
        });
    });

    // ==========================================
    // Animación de elementos orgánicos
    // ==========================================
    const organicShapes = document.querySelectorAll('.organic-shape, .organic-frame');
    
    organicShapes.forEach(shape => {
        // Añadir variación aleatoria a las animaciones
        const randomDelay = Math.random() * 2;
        const randomDuration = 15 + Math.random() * 10;
        
        shape.style.animationDelay = `${randomDelay}s`;
        shape.style.animationDuration = `${randomDuration}s`;
    });

    // ==========================================
    // Parallax suave en el Hero
    // ==========================================
    const heroVisual = document.querySelector('.hero-visual');
    
    if (heroVisual) {
        window.addEventListener('scroll', function() {
            const scrolled = window.pageYOffset;
            const rate = scrolled * -0.3;
            
            if (scrolled < window.innerHeight) {
                heroVisual.style.transform = `translateY(calc(-50% + ${rate}px))`;
            }
        });
    }

    // ==========================================
    // Animación de contadores (si se agregan estadísticas)
    // ==========================================
    function animateValue(obj, start, end, duration) {
        let startTimestamp = null;
        const step = (timestamp) => {
            if (!startTimestamp) startTimestamp = timestamp;
            const progress = Math.min((timestamp - startTimestamp) / duration, 1);
            obj.innerHTML = Math.floor(progress * (end - start) + start);
            if (progress < 1) {
                window.requestAnimationFrame(step);
            }
        };
        window.requestAnimationFrame(step);
    }

    // ==========================================
    // Lazy Loading para imágenes (si se agregan)
    // ==========================================
    const images = document.querySelectorAll('img[data-src]');
    
    if (images.length > 0) {
        const imageObserver = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const img = entry.target;
                    img.src = img.dataset.src;
                    img.classList.add('loaded');
                    imageObserver.unobserve(img);
                }
            });
        });

        images.forEach(img => imageObserver.observe(img));
    }

    // ==========================================
    // Efectos hover creativos para cards
    // ==========================================
    const cards = document.querySelectorAll('.value-card, .workshop-card, .testimonial-card');
    
    cards.forEach(card => {
        card.addEventListener('mouseenter', function(e) {
            const rect = this.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            
            this.style.setProperty('--mouse-x', `${x}px`);
            this.style.setProperty('--mouse-y', `${y}px`);
        });
    });

    // ==========================================
    // Filtro de talleres (para futura implementación)
    // ==========================================
    const workshopFilters = document.querySelectorAll('[data-filter]');
    const workshopCards = document.querySelectorAll('.workshop-card');
    
    workshopFilters.forEach(filter => {
        filter.addEventListener('click', function() {
            const filterValue = this.dataset.filter;
            
            // Remover clase activa de otros filtros
            workshopFilters.forEach(f => f.classList.remove('active'));
            this.classList.add('active');
            
            // Filtrar tarjetas
            workshopCards.forEach(card => {
                if (filterValue === 'all' || card.dataset.category === filterValue) {
                    card.style.display = 'block';
                    setTimeout(() => {
                        card.style.opacity = '1';
                        card.style.transform = 'scale(1)';
                    }, 10);
                } else {
                    card.style.opacity = '0';
                    card.style.transform = 'scale(0.9)';
                    setTimeout(() => {
                        card.style.display = 'none';
                    }, 300);
                }
            });
        });
    });

    // ==========================================
    // Formulario de contacto (placeholder)
    // ==========================================
    const ctaButtons = document.querySelectorAll('.btn');
    
    ctaButtons.forEach(button => {
        if (button.textContent.includes('Agendar') || button.textContent.includes('consulta')) {
            button.addEventListener('click', function(e) {
                e.preventDefault();
                
                // Aquí se podría abrir un modal o redirigir a un formulario
                console.log('Contacto iniciado:', this.textContent);
                
                // Animación de feedback
                this.style.transform = 'scale(0.95)';
                setTimeout(() => {
                    this.style.transform = '';
                }, 200);
                
                // Mostrar mensaje temporal
                const originalText = this.textContent;
                this.textContent = '¡Pronto nos contactaremos!';
                this.style.pointerEvents = 'none';
                
                setTimeout(() => {
                    this.textContent = originalText;
                    this.style.pointerEvents = '';
                }, 2000);
            });
        }
    });

    // ==========================================
    // Easter Egg: Mensaje en consola
    // ==========================================
    console.log('%c¿Te equivocaste? Bien. Estás haciendo. 🎨', 
                'color: #E86D5A; font-size: 16px; font-weight: bold; padding: 10px;');
    console.log('%cTrinomio - Un espacio donde hacer tenga sentido.', 
                'color: #2E5266; font-size: 12px;');

    // ==========================================
    // Performance: Debounce para resize
    // ==========================================
    let resizeTimer;
    window.addEventListener('resize', function() {
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(function() {
            // Recalcular elementos si es necesario
            AOS.refresh();
        }, 250);
    });

    // ==========================================
    // Accesibilidad: Focus visible
    // ==========================================
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Tab') {
            document.body.classList.add('keyboard-nav');
        }
    });

    document.addEventListener('mousedown', function() {
        document.body.classList.remove('keyboard-nav');
    });
});

// ==========================================
// Utilidades
// ==========================================

// Función para detectar si un elemento está en viewport
function isInViewport(element) {
    const rect = element.getBoundingClientRect();
    return (
        rect.top >= 0 &&
        rect.left >= 0 &&
        rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
        rect.right <= (window.innerWidth || document.documentElement.clientWidth)
    );
}

// Función para formatear números con separadores
function formatNumber(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
}

// ==========================================
// Exportar funciones si es necesario
// ==========================================
window.TrinomioUtils = {
    isInViewport,
    formatNumber
};