/* ============================================================
   UTILIDADES COMPARTIDAS - EMPLANORTE S.A.S.
   Sidebar, navegación, sesión, toasts y helpers reutilizables
   ============================================================ */

// ---- Verificar sesión activa ----
function checkSession() {
    const session = localStorage.getItem('emplanorte_session');
    if (!session) {
        window.location.href = '../index.html';
        return null;
    }
    return JSON.parse(session);
}

// ---- Obtener datos del usuario activo ----
function getUser() {
    const session = localStorage.getItem('emplanorte_session');
    return session ? JSON.parse(session) : null;
}

// ---- Cerrar sesión ----
function logout() {
    localStorage.removeItem('emplanorte_session');
    window.location.href = '../index.html';
}

// ---- Formatear moneda COP ----
function formatCurrency(value) {
    const num = Number(value) || 0;
    return '$ ' + num.toLocaleString('es-CO', { minimumFractionDigits: 0, maximumFractionDigits: 0 });
}

// ---- Formatear fecha legible ----
function formatDate(dateStr) {
    if (!dateStr) return '-';
    const d = new Date(dateStr);
    return d.toLocaleDateString('es-CO', { day: 'numeric', month: 'short', year: 'numeric' });
}

function formatDateTime(dateStr) {
    if (!dateStr) return '-';
    const d = new Date(dateStr);
    return d.toLocaleDateString('es-CO', { day: 'numeric', month: 'short', year: 'numeric' }) +
           ' ' + d.toLocaleTimeString('es-CO', { hour: '2-digit', minute: '2-digit' });
}

// ---- Fecha de hoy en formato YYYY-MM-DD ----
function todayISO() {
    return new Date().toISOString().split('T')[0];
}

// ---- Toast Notifications ----
function showToast(message, type = 'success') {
    let container = document.querySelector('.toast-container');
    if (!container) {
        container = document.createElement('div');
        container.className = 'toast-container';
        document.body.appendChild(container);
    }

    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.textContent = message;
    container.appendChild(toast);

    setTimeout(() => {
        toast.style.opacity = '0';
        toast.style.transform = 'translateX(30px)';
        setTimeout(() => toast.remove(), 300);
    }, 3500);
}

// ---- Iniciales del nombre ----
function getInitials(name) {
    if (!name) return '?';
    return name.split(' ').map(w => w[0]).join('').substring(0, 2).toUpperCase();
}

// ---- Render Sidebar (inyectar HTML) ----
function renderSidebar(activePage) {
    const user = getUser();
    const initials = user ? getInitials(user.nombre) : '?';
    const userName = user ? user.nombre : 'Usuario';
    const userRole = user ? (user.rol === 'superadmin' ? 'Super Admin' : 'Administrador') : '';

    const sidebarHTML = `
    <!-- Sidebar Toggle (mobile) -->
    <button class="sidebar-toggle" id="sidebarToggle" aria-label="Abrir menú">☰</button>
    <div class="sidebar-overlay" id="sidebarOverlay"></div>

    <aside class="sidebar" id="sidebar">
        <!-- Brand -->
        <div class="sidebar-brand">
            <div class="brand-icon">E</div>
            <span class="brand-name">EMPLANORTE</span>
        </div>

        <!-- User -->
        <div class="sidebar-user">
            <div class="user-avatar">${initials}</div>
            <div class="user-info">
                <div class="user-name">${userName}</div>
                <div class="user-role">${userRole}</div>
            </div>
        </div>

        <!-- Navigation -->
        <nav class="sidebar-nav">
            <div class="nav-section">
                <div class="nav-section-title">Gestiona tu Negocio</div>
                <a href="dashboard.html" class="nav-item ${activePage === 'dashboard' ? 'active' : ''}">
                    <span class="nav-icon">📊</span> Dashboard
                </a>
                <a href="ventas.html" class="nav-item ${activePage === 'ventas' ? 'active' : ''}">
                    <span class="nav-icon">💰</span> Ventas
                </a>
                <a href="gastos.html" class="nav-item ${activePage === 'gastos' ? 'active' : ''}">
                    <span class="nav-icon">📋</span> Gastos
                </a>
                <a href="inventario.html" class="nav-item ${activePage === 'inventario' ? 'active' : ''}">
                    <span class="nav-icon">📦</span> Inventario
                </a>
                <a href="cotizaciones.html" class="nav-item ${activePage === 'cotizaciones' ? 'active' : ''}">
                    <span class="nav-icon">📄</span> Cotizaciones
                </a>
            </div>

            <div class="nav-section">
                <div class="nav-section-title">Gestiona tus Contactos</div>
                <a href="clientes.html" class="nav-item ${activePage === 'clientes' ? 'active' : ''}">
                    <span class="nav-icon">👤</span> Clientes
                </a>
            </div>
        </nav>

        <!-- Footer -->
        <div class="sidebar-footer">
            <button class="btn-logout" id="btnLogout">
                <span>🚪</span> Cerrar Sesión
            </button>
            <div class="sidebar-version">v1.0.0</div>
        </div>
    </aside>
    `;

    // Insertar al inicio del body
    document.body.insertAdjacentHTML('afterbegin', sidebarHTML);

    // Event listeners
    document.getElementById('btnLogout').addEventListener('click', logout);

    // Mobile sidebar toggle
    const toggle = document.getElementById('sidebarToggle');
    const sidebar = document.getElementById('sidebar');
    const overlay = document.getElementById('sidebarOverlay');

    toggle.addEventListener('click', () => {
        sidebar.classList.toggle('open');
        overlay.classList.toggle('show');
    });

    overlay.addEventListener('click', () => {
        sidebar.classList.remove('open');
        overlay.classList.remove('show');
    });
}

// ---- Abrir / Cerrar Modal ----
function openModal(modalId) {
    document.getElementById(modalId).classList.add('show');
}

function closeModal(modalId) {
    document.getElementById(modalId).classList.remove('show');
}

// ---- Limpiar formulario ----
function resetForm(formId) {
    document.getElementById(formId).reset();
}
