package com.emplanorte.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ItemCotizacionRequest {
    private Long idProducto;
    private Integer cantidad;
}
