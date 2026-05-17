/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.falyd.conexion;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
/**
 *
 * @author Alfredo
 */
public class Conexion {
    // Configuración de la base de datos
    private static final String URL = "jdbc:mysql://localhost:3306/peep_db";
    private static final String USER = "root";
    private static final String PASSWORD = "mapaches"; 
    
   public static Connection getConexion() {
        Connection con = null;
        try {
            // Cargar el driver de MySQL (Asegúrate de tener el .jar en Libraries)
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establecer la conexión
            con = DriverManager.getConnection(URL, USER, PASSWORD);
            System.out.println("Conexion exitosa a la base de datos peep_db");
            
        } catch (ClassNotFoundException e) {
            System.out.println("Error: No se encontro el driver de MySQL en las librerias.");
        } catch (SQLException e) {
            System.out.println("Error al conectar con la base de datos: " + e.getMessage());
        }
        return con;
    }
   
}
