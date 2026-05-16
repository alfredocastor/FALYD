/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.falyd.modelo;

/**
 *
 * @author Alfredo
 */
public class Calificacion {
    private int id_calificacion;
    private int id_alumno;
    private int id_tarea;
    private double calificacion;

    public Calificacion() {
    }

    public int getId_calificacion() { return id_calificacion; }
    public void setId_calificacion(int id_calificacion) { this.id_calificacion = id_calificacion; }

    public int getId_alumno() { return id_alumno; }
    public void setId_alumno(int id_alumno) { this.id_alumno = id_alumno; }

    public int getId_tarea() { return id_tarea; }
    public void setId_tarea(int id_tarea) { this.id_tarea = id_tarea; }

    public double getCalificacion() { return calificacion; }
    public void setCalificacion(double calificacion) { this.calificacion = calificacion; }
}