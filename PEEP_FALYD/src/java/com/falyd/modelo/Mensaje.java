/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.falyd.modelo;

/**
 *
 * @author Alfredo
 */
public class Mensaje {
    private int id_mensaje;
    private int id_emisor;
    private int id_receptor;
    private String contenido;
    private String fecha_envio;
    private boolean leido;

    public Mensaje() {}

    public int getId_mensaje() { return id_mensaje; }
    public void setId_mensaje(int id_mensaje) { this.id_mensaje = id_mensaje; }

    public int getId_emisor() { return id_emisor; }
    public void setId_emisor(int id_emisor) { this.id_emisor = id_emisor; }

    public int getId_receptor() { return id_receptor; }
    public void setId_receptor(int id_receptor) { this.id_receptor = id_receptor; }

    public String getContenido() { return contenido; }
    public void setContenido(String contenido) { this.contenido = contenido; }

    public String getFecha_envio() { return fecha_envio; }
    public void setFecha_envio(String fecha_envio) { this.fecha_envio = fecha_envio; }

    public boolean isLeido() { return leido; }
    public void setLeido(boolean leido) { this.leido = leido; }
}