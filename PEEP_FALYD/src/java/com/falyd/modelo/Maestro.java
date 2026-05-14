/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.falyd.modelo;

/**
 *
 * @author Alfredo
 */
public class Maestro {
    private int id_maestro;
    private String nombre; // El nombre lo traeremos de la tabla USUARIO

    public Maestro() {
    }

    public int getId_maestro() { return id_maestro; }
    public void setId_maestro(int id_maestro) { this.id_maestro = id_maestro; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
}