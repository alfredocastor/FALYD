/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.falyd.modelo;

/**
 *
 * @author Alfredo
 */
public class Evento {
    private int id_evento;
    private String titulo;
    private String tipo_evento;
    private String description;
    private String color;
    private String fecha_inicio;
    private String hora_inicio;
    private String fecha_fin;
    private String hora_fin;
    private boolean todo_el_dia;
    private int id_materia;
    private int id_maestro;
    private String nombre_materia; // Auxiliar para la interfaz

    public Evento() {}

    public int getId_evento() { return id_evento; }
    public void setId_evento(int id_evento) { this.id_evento = id_evento; }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public String getTipo_evento() { return tipo_evento; }
    public void setTipo_evento(String tipo_evento) { this.tipo_evento = tipo_evento; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }

    public String getFecha_inicio() { return fecha_inicio; }
    public void setFecha_inicio(String fecha_inicio) { this.fecha_inicio = fecha_inicio; }

    public String getHora_inicio() { return hora_inicio; }
    public void setHora_inicio(String hora_inicio) { this.hora_inicio = hora_inicio; }

    public String getFecha_fin() { return fecha_fin; }
    public void setFecha_fin(String fecha_fin) { this.fecha_fin = fecha_fin; }

    public String getHora_fin() { return hora_fin; }
    public void setHora_fin(String hora_fin) { this.hora_fin = hora_fin; }

    public boolean isTodo_el_dia() { return todo_el_dia; }
    public void setTodo_el_dia(boolean todo_el_dia) { this.todo_el_dia = todo_el_dia; }

    public int getId_materia() { return id_materia; }
    public void setId_materia(int id_materia) { this.id_materia = id_materia; }

    public int getId_maestro() { return id_maestro; }
    public void setId_maestro(int id_maestro) { this.id_maestro = id_maestro; }

    public String getNombre_materia() { return nombre_materia; }
    public void setNombre_materia(String nombre_materia) { this.nombre_materia = nombre_materia; }
}
