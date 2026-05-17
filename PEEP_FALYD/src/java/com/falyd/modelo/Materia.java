/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.falyd.modelo;

/**
 *
 * @author Alfredo
 */
public class Materia {
    private int id_materia;
    private String nombre_materia;
    private int id_maestro;
    
    private String nombre_maestro; 
    private double promedio;

    public Materia() {
    }

    public int getId_materia() { return id_materia; }
    public void setId_materia(int id_materia) { this.id_materia = id_materia; }

    public String getNombre_materia() { return nombre_materia; }
    public void setNombre_materia(String nombre_materia) { this.nombre_materia = nombre_materia; }

    public int getId_maestro() { return id_maestro; }
    public void setId_maestro(int id_maestro) { this.id_maestro = id_maestro; }

    public String getNombre_maestro() { return nombre_maestro; }
    public void setNombre_maestro(String nombre_maestro) { this.nombre_maestro = nombre_maestro; }
    
    public double getPromedio() { return promedio; }
    public void setPromedio(double promedio) { this.promedio = promedio; }
}