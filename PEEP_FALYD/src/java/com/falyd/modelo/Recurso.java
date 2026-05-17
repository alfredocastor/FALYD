/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.falyd.modelo;

/**
 *
 * @author Alfredo
 */
public class Recurso {
    private int id_recurso;
    private String titulo;
    private String descripcion;
    private String tipo_recurso;
    private String url_recurso;
    private String fecha_publicacion;
    private int id_materia;
    private int id_maestro;
    private String nombre_materia; 

    public Recurso() {}

    public int getId_recurso() { return id_recurso; }
    public void setId_recurso(int id_recurso) { this.id_recurso = id_recurso; }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public String getTipo_recurso() { return tipo_recurso; }
    public void setTipo_recurso(String tipo_recurso) { this.tipo_recurso = tipo_recurso; }

    public String getUrl_recurso() { return url_recurso; }
    public void setUrl_recurso(String url_recurso) { this.url_recurso = url_recurso; }

    public String getFecha_publicacion() { return fecha_publicacion; }
    public void setFecha_publicacion(String fecha_publicacion) { this.fecha_publicacion = fecha_publicacion; }

    public int getId_materia() { return id_materia; }
    public void setId_materia(int id_materia) { this.id_materia = id_materia; }

    public int getId_maestro() { return id_maestro; }
    public void setId_maestro(int id_maestro) { this.id_maestro = id_maestro; }

    public String getNombre_materia() { return nombre_materia; }
    public void setNombre_materia(String nombre_materia) { this.nombre_materia = nombre_materia; }
}

