/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.falyd.modelo;

/**
 *
 * @author Alfredo
 */
public class Entrega {
    private int id_entrega;
    private int id_tarea;
    private int id_alumno;
    private String archivo_url;
    private String comentario_alumno;
    private String fecha_envio;
    
    private String nombre_alumno;

    public Entrega() {
    }

    public int getId_entrega() { return id_entrega; }
    public void setId_entrega(int id_entrega) { this.id_entrega = id_entrega; }

    public int getId_tarea() { return id_tarea; }
    public void setId_tarea(int id_tarea) { this.id_tarea = id_tarea; }

    public int getId_alumno() { return id_alumno; }
    public void setId_alumno(int id_alumno) { this.id_alumno = id_alumno; }

    public String getArchivo_url() { return archivo_url; }
    public void setArchivo_url(String archivo_url) { this.archivo_url = archivo_url; }

    public String getComentario_alumno() { return comentario_alumno; }
    public void setComentario_alumno(String comentario_alumno) { this.comentario_alumno = comentario_alumno; }

    public String getFecha_envio() { return fecha_envio; }
    public void setFecha_envio(String fecha_envio) { this.fecha_envio = fecha_envio; }

    public String getNombre_alumno() { return nombre_alumno; }
    public void setNombre_alumno(String nombre_alumno) { this.nombre_alumno = nombre_alumno; }
}
