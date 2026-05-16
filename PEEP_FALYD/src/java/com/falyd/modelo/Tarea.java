/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.falyd.modelo;

/**
 *
 * @author Alfredo
 */
public class Tarea {
    private int id_tarea;
    private String titulo;
    private String descripcion;
    private String fecha_entrega; 
    private int id_maestro;
    private int id_materia;
    

    private String nombre_materia;

    public Tarea() {
    }

    public int getId_tarea() { return id_tarea; }
    public void setId_tarea(int id_tarea) { this.id_tarea = id_tarea; }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public String getFecha_entrega() { return fecha_entrega; }
    public void setFecha_entrega(String fecha_entrega) { this.fecha_entrega = fecha_entrega; }

    public int getId_maestro() { return id_maestro; }
    public void setId_maestro(int id_maestro) { this.id_maestro = id_maestro; }

    public int getId_materia() { return id_materia; }
    public void setId_materia(int id_materia) { this.id_materia = id_materia; }

    public String getNombre_materia() { return nombre_materia; }
    public void setNombre_materia(String nombre_materia) { this.nombre_materia = nombre_materia; }
}