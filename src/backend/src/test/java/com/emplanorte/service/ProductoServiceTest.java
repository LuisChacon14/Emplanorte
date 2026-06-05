package com.emplanorte.service;

import com.emplanorte.model.CategoriaProducto;
import com.emplanorte.model.Producto;
import com.emplanorte.repository.ProductoRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Sort;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("ProductoService — RF01, RF02, RF03, RF04")
class ProductoServiceTest {

    @Mock private ProductoRepository productoRepository;
    @InjectMocks private ProductoService productoService;

    private CategoriaProducto categoria;
    private Producto productoBase;

    @BeforeEach
    void setUp() {
        categoria = new CategoriaProducto();
        categoria.setId(1L);
        categoria.setNombre("PET");
        categoria.setActivo(true);

        productoBase = new Producto();
        productoBase.setId(1L);
        productoBase.setCodigo("PET-500");
        productoBase.setNombre("Botella PET 500ml");
        productoBase.setCategoria(categoria);
        productoBase.setCapacidadMl(new BigDecimal("500"));
        productoBase.setCostoUnitario(new BigDecimal("1000"));
        productoBase.setPrecioVenta(new BigDecimal("1500"));
        productoBase.setStockDisponible(100);
        productoBase.setStockMinimo(10);
        productoBase.setUnidadMedida("unidad");
        productoBase.setActivo(true);
    }

    // ─── RF01  Registro de productos ─────────────────────────────────────────

    @Test
    @DisplayName("CP-01: Guardar producto con datos completos — queda activo y persistido")
    void guardar_productoCompleto_quedaActivoYPersistido() {
        Producto nuevo = new Producto();
        nuevo.setNombre("Botella PET 500ml");
        nuevo.setCategoria(categoria);
        nuevo.setCostoUnitario(new BigDecimal("1000"));
        nuevo.setPrecioVenta(new BigDecimal("1500"));
        nuevo.setStockDisponible(100);
        when(productoRepository.save(any(Producto.class))).thenAnswer(inv -> inv.getArgument(0));

        Producto resultado = productoService.guardar(nuevo);

        assertThat(resultado.getActivo()).isTrue();
        verify(productoRepository).save(nuevo);
    }

    @Test
    @DisplayName("CP-08: Todos los campos del producto se almacenan sin pérdida de información")
    void guardar_todosLosCampos_ninguncambiaDatos() {
        when(productoRepository.save(any(Producto.class))).thenAnswer(inv -> inv.getArgument(0));

        Producto resultado = productoService.guardar(productoBase);

        assertThat(resultado.getCodigo()).isEqualTo("PET-500");
        assertThat(resultado.getNombre()).isEqualTo("Botella PET 500ml");
        assertThat(resultado.getCategoria().getNombre()).isEqualTo("PET");
        assertThat(resultado.getCapacidadMl()).isEqualByComparingTo(new BigDecimal("500"));
        assertThat(resultado.getCostoUnitario()).isEqualByComparingTo(new BigDecimal("1000"));
        assertThat(resultado.getPrecioVenta()).isEqualByComparingTo(new BigDecimal("1500"));
        assertThat(resultado.getStockDisponible()).isEqualTo(100);
        assertThat(resultado.getStockMinimo()).isEqualTo(10);
        assertThat(resultado.getUnidadMedida()).isEqualTo("unidad");
    }

    @Test
    @DisplayName("CP-09: Capacidad decimal (250.5 ml) se almacena con precisión exacta")
    void guardar_capacidadDecimal_sinPerdidaDePrecision() {
        Producto producto = new Producto();
        producto.setCapacidadMl(new BigDecimal("250.5"));
        when(productoRepository.save(any(Producto.class))).thenAnswer(inv -> inv.getArgument(0));

        Producto resultado = productoService.guardar(producto);

        assertThat(resultado.getCapacidadMl()).isEqualByComparingTo(new BigDecimal("250.5"));
    }

    @Test
    @DisplayName("Listar activos — solo retorna productos con activo=true")
    void obtenerTodosActivos_soloRetornaActivos() {
        when(productoRepository.findByActivoTrue()).thenReturn(List.of(productoBase));

        List<Producto> resultado = productoService.obtenerTodosActivos();

        assertThat(resultado).hasSize(1);
        assertThat(resultado.get(0).getActivo()).isTrue();
    }

    // ─── RF02  Modificación y eliminación ────────────────────────────────────

    @Test
    @DisplayName("CP-05: Actualizar producto existente — nuevos valores quedan guardados")
    void actualizar_productoExistente_camposActualizados() {
        Producto cambios = new Producto();
        cambios.setCodigo("PET-500-V2");
        cambios.setNombre("Botella PET 500ml Premium");
        cambios.setCategoria(categoria);
        cambios.setCapacidadMl(new BigDecimal("500"));
        cambios.setCostoUnitario(new BigDecimal("1100"));
        cambios.setPrecioVenta(new BigDecimal("1700"));
        cambios.setStockDisponible(80);
        cambios.setStockMinimo(10);
        cambios.setUnidadMedida("unidad");

        when(productoRepository.findById(1L)).thenReturn(Optional.of(productoBase));
        when(productoRepository.save(any(Producto.class))).thenAnswer(inv -> inv.getArgument(0));

        Producto resultado = productoService.actualizar(1L, cambios);

        assertThat(resultado.getNombre()).isEqualTo("Botella PET 500ml Premium");
        assertThat(resultado.getPrecioVenta()).isEqualByComparingTo(new BigDecimal("1700"));
        assertThat(resultado.getCostoUnitario()).isEqualByComparingTo(new BigDecimal("1100"));
        assertThat(resultado.getStockDisponible()).isEqualTo(80);
    }

    @Test
    @DisplayName("CP-05b: Actualizar producto inexistente — RuntimeException con el ID")
    void actualizar_productoNoExiste_lanzaExcepcion() {
        when(productoRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> productoService.actualizar(99L, productoBase))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("99");
    }

    @Test
    @DisplayName("CP-06/CP-07: Desactivar producto — activo pasa a false, no se elimina físicamente")
    void desactivar_producto_marcaInactivoSinBorrar() {
        when(productoRepository.findById(1L)).thenReturn(Optional.of(productoBase));
        when(productoRepository.save(any(Producto.class))).thenAnswer(inv -> inv.getArgument(0));

        productoService.desactivar(1L);

        assertThat(productoBase.getActivo()).isFalse();
        verify(productoRepository).save(productoBase);
        verify(productoRepository, never()).deleteById(any());
    }

    @Test
    @DisplayName("CP-06b: Desactivar producto inexistente — RuntimeException con el ID")
    void desactivar_productoNoExiste_lanzaExcepcion() {
        when(productoRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> productoService.desactivar(99L))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("99");
    }

    // ─── RF03  Consulta individual ────────────────────────────────────────────

    @Test
    @DisplayName("Obtener por ID — producto activo se retorna correctamente")
    void obtenerPorId_productoActivo_retornaProducto() {
        when(productoRepository.findById(1L)).thenReturn(Optional.of(productoBase));

        Optional<Producto> resultado = productoService.obtenerPorId(1L);

        assertThat(resultado).isPresent();
        assertThat(resultado.get().getNombre()).isEqualTo("Botella PET 500ml");
    }

    @Test
    @DisplayName("Obtener por ID — producto inactivo no se retorna (filtra lógicamente)")
    void obtenerPorId_productoInactivo_retornaVacio() {
        productoBase.setActivo(false);
        when(productoRepository.findById(1L)).thenReturn(Optional.of(productoBase));

        Optional<Producto> resultado = productoService.obtenerPorId(1L);

        assertThat(resultado).isEmpty();
    }

    // ─── RF04  Ordenamiento ───────────────────────────────────────────────────

    @Test
    @DisplayName("CP-10: Ordenar por nombre — Sort usa campo 'nombre' ASC")
    void ordenar_porNombre_usaCampoNombreAscendente() {
        ArgumentCaptor<Sort> captor = ArgumentCaptor.forClass(Sort.class);
        when(productoRepository.findAll(captor.capture())).thenReturn(List.of(productoBase));

        productoService.obtenerTodosActivosOrdenados("nombre");

        Sort.Order orden = captor.getValue().getOrderFor("nombre");
        assertThat(orden).isNotNull();
        assertThat(orden.getDirection()).isEqualTo(Sort.Direction.ASC);
    }

    @Test
    @DisplayName("CP-10b: Ordenar por nombre — filtra y excluye productos inactivos")
    void ordenar_porNombre_soloRetornaActivos() {
        Producto inactivo = new Producto();
        inactivo.setNombre("Producto inactivo");
        inactivo.setActivo(false);

        when(productoRepository.findAll(any(Sort.class))).thenReturn(List.of(productoBase, inactivo));

        List<Producto> resultado = productoService.obtenerTodosActivosOrdenados("nombre");

        assertThat(resultado).hasSize(1);
        assertThat(resultado.get(0).getNombre()).isEqualTo("Botella PET 500ml");
    }

    @Test
    @DisplayName("CP-11: Ordenar por stock — Sort usa campo 'stockDisponible' ASC")
    void ordenar_porStock_usaCampoStockDisponibleAscendente() {
        ArgumentCaptor<Sort> captor = ArgumentCaptor.forClass(Sort.class);
        when(productoRepository.findAll(captor.capture())).thenReturn(List.of(productoBase));

        productoService.obtenerTodosActivosOrdenados("stock");

        Sort.Order orden = captor.getValue().getOrderFor("stockDisponible");
        assertThat(orden).isNotNull();
        assertThat(orden.getDirection()).isEqualTo(Sort.Direction.ASC);
    }

    @Test
    @DisplayName("CP-11b: Ordenar por tamaño — Sort usa campo 'capacidadMl' ASC")
    void ordenar_porTamano_usaCampoCapacidadMlAscendente() {
        ArgumentCaptor<Sort> captor = ArgumentCaptor.forClass(Sort.class);
        when(productoRepository.findAll(captor.capture())).thenReturn(List.of(productoBase));

        productoService.obtenerTodosActivosOrdenados("tamano");

        Sort.Order orden = captor.getValue().getOrderFor("capacidadMl");
        assertThat(orden).isNotNull();
        assertThat(orden.getDirection()).isEqualTo(Sort.Direction.ASC);
    }

    @Test
    @DisplayName("CP-12: Inventario vacío — retorna lista vacía sin lanzar excepción")
    void ordenar_inventarioVacio_retornaListaVaciaSinError() {
        when(productoRepository.findAll(any(Sort.class))).thenReturn(Collections.emptyList());

        List<Producto> resultado = productoService.obtenerTodosActivosOrdenados("nombre");

        assertThat(resultado).isEmpty();
    }

    @Test
    @DisplayName("CP-12b: Criterio nulo — usa ordenamiento por defecto (nombre) sin error")
    void ordenar_criterioCero_usaOrdenPorDefectoSinError() {
        when(productoRepository.findAll(any(Sort.class))).thenReturn(List.of(productoBase));

        assertThatCode(() -> productoService.obtenerTodosActivosOrdenados(null))
                .doesNotThrowAnyException();
    }

    @Test
    @DisplayName("Partición: ordenar por categoría — Sort usa campo 'categoria.nombre'")
    void ordenar_porCategoria_usaCampoCategoriaNombre() {
        ArgumentCaptor<Sort> captor = ArgumentCaptor.forClass(Sort.class);
        when(productoRepository.findAll(captor.capture())).thenReturn(List.of(productoBase));

        productoService.obtenerTodosActivosOrdenados("categoria");

        Sort.Order orden = captor.getValue().getOrderFor("categoria.nombre");
        assertThat(orden).isNotNull();
    }
}
