/* ============================================================
   CLIENTE API - EMPLANORTE S.A.S.
   Wrapper de comunicación con el backend (http://localhost:8080/api)
   ============================================================ */

const API_BASE_URL = 'http://localhost:8080/api';

const ApiClient = {
    // Utilidad interna para peticiones fetch
    async request(endpoint, options = {}) {
        const url = `${API_BASE_URL}${endpoint}`;
        
        // Configurar encabezados por defecto
        const headers = {
            'Content-Type': 'application/json',
            ...options.headers
        };

        // Obtener el token de localStorage si existe
        const session = localStorage.getItem('emplanorte_session');
        if (session) {
            const { token } = JSON.parse(session);
            if (token) {
                headers['Authorization'] = `Bearer ${token}`;
            }
        }

        const config = {
            ...options,
            headers
        };

        try {
            const response = await fetch(url, config);
            
            // Si la respuesta es no content (204)
            if (response.status === 204) {
                return true;
            }

            const data = await response.json();
            
            if (!response.ok) {
                throw new Error(data.message || data || 'Error en la petición');
            }
            
            return data;
        } catch (error) {
            console.error(`Error en API request [${url}]:`, error);
            throw error;
        }
    },

    // ==========================================
    // 1. MÓDULO AUTENTICACIÓN
    // ==========================================
    async login(correo, contrasena) {
        return this.request('/auth/login', {
            method: 'POST',
            body: JSON.stringify({ correo, contrasena })
        });
    },

    logout() {
        localStorage.removeItem('emplanorte_session');
        window.location.href = '../index.html';
    },

    // ==========================================
    // 2. MÓDULO INVENTARIO (RF01-RF04)
    // ==========================================
    async listarProductos(ordenarPor = null) {
        const query = ordenarPor ? `?ordenarPor=${ordenarPor}` : '';
        return this.request(`/productos${query}`, { method: 'GET' });
    },

    async obtenerProducto(id) {
        return this.request(`/productos/${id}`, { method: 'GET' });
    },

    async crearProducto(producto) {
        return this.request('/productos', {
            method: 'POST',
            body: JSON.stringify(producto)
        });
    },

    async actualizarProducto(id, producto) {
        return this.request(`/productos/${id}`, {
            method: 'PUT',
            body: JSON.stringify(producto)
        });
    },

    async eliminarProducto(id) {
        return this.request(`/productos/${id}`, { method: 'DELETE' });
    },

    // ==========================================
    // 3. MÓDULO CLIENTES (RF13)
    // ==========================================
    async listarClientes() {
        return this.request('/clientes', { method: 'GET' });
    },

    async obtenerCliente(id) {
        return this.request(`/clientes/${id}`, { method: 'GET' });
    },

    async crearCliente(cliente) {
        return this.request('/clientes', {
            method: 'POST',
            body: JSON.stringify(cliente)
        });
    },

    async actualizarCliente(id, cliente) {
        return this.request(`/clientes/${id}`, {
            method: 'PUT',
            body: JSON.stringify(cliente)
        });
    },

    async eliminarCliente(id) {
        return this.request(`/clientes/${id}`, { method: 'DELETE' });
    },

    // ==========================================
    // 4. MÓDULO GASTOS (RF09, RF10)
    // ==========================================
    async listarGastos() {
        return this.request('/gastos', { method: 'GET' });
    },

    async listarGastosPorRango(desde, hasta) {
        return this.request(`/gastos/rango?desde=${desde}&hasta=${hasta}`, { method: 'GET' });
    },

    async registrarGasto(gasto) {
        return this.request('/gastos', {
            method: 'POST',
            body: JSON.stringify(gasto)
        });
    },

    async listarCategoriasGasto() {
        return this.request('/gastos/categorias', { method: 'GET' });
    },

    async crearCategoriaGasto(categoria) {
        return this.request('/gastos/categorias', {
            method: 'POST',
            body: JSON.stringify(categoria)
        });
    },

    // ==========================================
    // 5. MÓDULO VENTAS (RF05-RF08)
    // ==========================================
    async listarVentas() {
        return this.request('/ventas', { method: 'GET' });
    },

    async registrarVenta(ventaRequest) {
        return this.request('/ventas', {
            method: 'POST',
            body: JSON.stringify(ventaRequest)
        });
    },

    // ==========================================
    // 6. MÓDULO COTIZACIONES (RF14)
    // ==========================================
    async listarCotizaciones() {
        return this.request('/cotizaciones', { method: 'GET' });
    },

    async crearCotizacion(cotizacionRequest) {
        return this.request('/cotizaciones', {
            method: 'POST',
            body: JSON.stringify(cotizacionRequest)
        });
    },

    async convertirCotizacionAVenta(id, metodoPago) {
        return this.request(`/cotizaciones/convertir/${id}`, {
            method: 'POST',
            body: JSON.stringify({ metodoPago })
        });
    },

    // ==========================================
    // 7. MÓDULO DASHBOARD & REPORTES (RF11, RF12)
    // ==========================================
    async obtenerResumenDashboard(desde, hasta) {
        return this.request(`/dashboard/resumen?desde=${desde}&hasta=${hasta}`, { method: 'GET' });
    }
};
