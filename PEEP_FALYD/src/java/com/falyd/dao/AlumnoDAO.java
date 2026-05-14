/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.falyd.dao;

import com.falyd.conexion.Conexion;
import com.falyd.modelo.Alumno;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 *
 * @author Alfredo
 */
public class AlumnoDAO {

    // Método para registrar un alumno en las tablas USUARIO y ALUMNO
    public boolean registrarAlumno(String nombre, String correo, String password, int id_grupo) {
        boolean registrado = false;
        Connection con = null;
        PreparedStatement psUsuario = null;
        PreparedStatement psAlumno = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConexion();

            // 1. Preparamos el INSERT para la tabla USUARIO
            // Statement.RETURN_GENERATED_KEYS nos permite obtener el id_usuario que MySQL asigne
            String sqlUsuario = "INSERT INTO USUARIO (nombre, correo, password, tipo_usuario) VALUES (?, ?, ?, 'ALUMNO')";
            psUsuario = con.prepareStatement(sqlUsuario, Statement.RETURN_GENERATED_KEYS);
            psUsuario.setString(1, nombre);
            psUsuario.setString(2, correo);
            psUsuario.setString(3, password);

            // Ejecutamos el primer INSERT
            int filasUsuario = psUsuario.executeUpdate();

            // Si se insertó el usuario correctamente, procedemos con la tabla ALUMNO
            if (filasUsuario > 0) {
                rs = psUsuario.getGeneratedKeys(); // Obtenemos el ID generado

                if (rs.next()) {
                    int idUsuarioGenerado = rs.getInt(1);

                    // 2. Preparamos el INSERT para la tabla ALUMNO
                    String sqlAlumno = "INSERT INTO ALUMNO (id_usuario, id_grupo) VALUES (?, ?)";
                    psAlumno = con.prepareStatement(sqlAlumno);
                    psAlumno.setInt(1, idUsuarioGenerado);
                    psAlumno.setInt(2, id_grupo);

                    // Ejecutamos el segundo INSERT
                    int filasAlumno = psAlumno.executeUpdate();
                    if (filasAlumno > 0) {
                        registrado = true; // ¡Todo salió perfecto!
                    }
                }
            }
        } catch (Exception e) {
            System.out.println("Error al registrar alumno en BD: " + e.getMessage());
        } finally {
            // Cerramos las conexiones para liberar memoria
            try {
                if (rs != null) {
                    rs.close();
                }
                if (psUsuario != null) {
                    psUsuario.close();
                }
                if (psAlumno != null) {
                    psAlumno.close();
                }
                if (con != null) {
                    con.close();
                }
            } catch (Exception e) {
                System.out.println("Error al cerrar conexión: " + e.getMessage());
            }
        }

        return registrado;
    }

    public java.util.List<Alumno> listarAlumnos() {
        java.util.List<Alumno> lista = new java.util.ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql = "SELECT a.id_alumno, a.id_usuario, a.id_grupo, u.nombre, u.correo, g.nombre_grupo "
                + "FROM ALUMNO a "
                + "INNER JOIN USUARIO u ON a.id_usuario = u.id_usuario "
                + "INNER JOIN GRUPO g ON a.id_grupo = g.id_grupo "
                + "ORDER BY a.id_alumno DESC";

        try {
            con = Conexion.getConexion();
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                Alumno alu = new Alumno();
                alu.setId_alumno(rs.getInt("id_alumno"));
                alu.setId_usuario(rs.getInt("id_usuario"));
                alu.setId_grupo(rs.getInt("id_grupo"));
                alu.setNombre(rs.getString("nombre"));
                alu.setCorreo(rs.getString("correo"));
                alu.setNombre_grupo(rs.getString("nombre_grupo"));
                lista.add(alu);
            }
        } catch (Exception e) {
            System.out.println("Error al listar alumnos: " + e.getMessage());
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (ps != null) {
                    ps.close();
                }
                if (con != null) {
                    con.close();
                }
            } catch (Exception e) {
            }
        }
        return lista;
    }
    // Método para editar un alumno
    public boolean editarAlumno(int id_usuario, int id_alumno, String nombre, String correo, String password, int id_grupo) {
        boolean editado = false;
        Connection con = null;
        PreparedStatement psUsuario = null;
        PreparedStatement psAlumno = null;

        try {
            con = Conexion.getConexion();
            
            // 1. Actualizamos la tabla USUARIO
            String sqlUsuario;
            // Si mandó contraseña, la actualizamos. Si está vacía, la dejamos igual.
            if (password != null && !password.trim().isEmpty()) {
                sqlUsuario = "UPDATE USUARIO SET nombre = ?, correo = ?, password = ? WHERE id_usuario = ?";
                psUsuario = con.prepareStatement(sqlUsuario);
                psUsuario.setString(1, nombre);
                psUsuario.setString(2, correo);
                psUsuario.setString(3, password);
                psUsuario.setInt(4, id_usuario);
            } else {
                sqlUsuario = "UPDATE USUARIO SET nombre = ?, correo = ? WHERE id_usuario = ?";
                psUsuario = con.prepareStatement(sqlUsuario);
                psUsuario.setString(1, nombre);
                psUsuario.setString(2, correo);
                psUsuario.setInt(3, id_usuario);
            }
            
            psUsuario.executeUpdate();

            // 2. Actualizamos la tabla ALUMNO (su grupo)
            String sqlAlumno = "UPDATE ALUMNO SET id_grupo = ? WHERE id_alumno = ?";
            psAlumno = con.prepareStatement(sqlAlumno);
            psAlumno.setInt(1, id_grupo);
            psAlumno.setInt(2, id_alumno);
            
            int filasAlumno = psAlumno.executeUpdate();
            if (filasAlumno > 0) {
                editado = true;
            }

        } catch (Exception e) {
            System.out.println("Error al editar alumno: " + e.getMessage());
        } finally {
            try {
                if (psUsuario != null) psUsuario.close();
                if (psAlumno != null) psAlumno.close();
                if (con != null) con.close();
            } catch (Exception e) {}
        }
        return editado;
    }
    // Método para eliminar un alumno completamente del sistema
    public boolean eliminarAlumno(int id_usuario, int id_alumno) {
        boolean eliminado = false;
        Connection con = null;
        PreparedStatement psAlumno = null;
        PreparedStatement psUsuario = null;

        try {
            con = Conexion.getConexion();
            
            // 1. Primero borramos de la tabla hija (ALUMNO)
            String sqlAlumno = "DELETE FROM ALUMNO WHERE id_alumno = ?";
            psAlumno = con.prepareStatement(sqlAlumno);
            psAlumno.setInt(1, id_alumno);
            int filasAlumno = psAlumno.executeUpdate();

            // 2. Si se borró el alumno, borramos al usuario base (USUARIO)
            if (filasAlumno > 0) {
                String sqlUsuario = "DELETE FROM USUARIO WHERE id_usuario = ?";
                psUsuario = con.prepareStatement(sqlUsuario);
                psUsuario.setInt(1, id_usuario);
                
                int filasUsuario = psUsuario.executeUpdate();
                if (filasUsuario > 0) {
                    eliminado = true; // ¡Eliminación completa!
                }
            }
        } catch (Exception e) {
            System.out.println("Error al eliminar alumno: " + e.getMessage());
        } finally {
            try {
                if (psAlumno != null) psAlumno.close();
                if (psUsuario != null) psUsuario.close();
                if (con != null) con.close();
            } catch (Exception e) {}
        }
        return eliminado;
    }
}
