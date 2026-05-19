/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.falyd.controlador;

import com.falyd.dao.AlumnoDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author Alfredo
 */
public class AlumnoServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Configuramos para que acepte acentos y la letra ñ correctamente
        request.setCharacterEncoding("UTF-8");
        
        // Atrapamos la acción oculta que le pusimos al formulario
        String accion = request.getParameter("accion");

        if ("agregar".equals(accion)) {
            // 1. Recibimos los datos que escribió la Secretaria en el Modal
            String nombre = request.getParameter("nombre");
            String correo = request.getParameter("correo");
            String password = request.getParameter("password");
            
            // Convertimos el ID del grupo a número porque del formulario siempre llega como texto
            int id_grupo = Integer.parseInt(request.getParameter("id_grupo"));

            // 2. Se los mandamos al DAO para que los guarde en MySQL
            AlumnoDAO dao = new AlumnoDAO();
            boolean exito = dao.registrarAlumno(nombre, correo, password, id_grupo);

            // 3. Respondemos a la vista
            if (exito) {
                // Si todo salió bien, recargamos el panel enviando una señal de éxito
                response.sendRedirect("panel_secretaria.jsp?msg=exito");
            } else {
                // Si falló, enviamos una señal de error
                response.sendRedirect("panel_secretaria.jsp?msg=error");
            }
        }else if ("editar".equals(accion)) {
            // 1. Recibimos los datos del modal de Edición
            int id_usuario = Integer.parseInt(request.getParameter("id_usuario"));
            int id_alumno = Integer.parseInt(request.getParameter("id_alumno"));
            String nombre = request.getParameter("nombre");
            String correo = request.getParameter("correo");
            String password = request.getParameter("password");
            int id_grupo = Integer.parseInt(request.getParameter("id_grupo"));

            if (password != null && !password.trim().isEmpty()) {
                if (password.length() < 6) {
                    response.sendRedirect("panel_secretaria.jsp?error=password_corta");
                    return; // Detiene la ejecución aquí
                }
            }
            // 2. Mandamos al DAO
            AlumnoDAO dao = new AlumnoDAO();
            boolean exito = dao.editarAlumno(id_usuario, id_alumno, nombre, correo, password, id_grupo);

            // 3. Respondemos
            if (exito) {
                response.sendRedirect("panel_secretaria.jsp?msg=editado");
            } else {
                response.sendRedirect("panel_secretaria.jsp?msg=error");
            }
        }else if ("eliminar".equals(accion)) {
            // 1. Recibimos los IDs desde el modal de confirmación
            int id_usuario = Integer.parseInt(request.getParameter("id_usuario"));
            int id_alumno = Integer.parseInt(request.getParameter("id_alumno"));

            // 2. Mandamos la orden de ejecución al DAO
            AlumnoDAO dao = new AlumnoDAO();
            boolean exito = dao.eliminarAlumno(id_usuario, id_alumno);

            // 3. Redirigimos con un mensaje
            if (exito) {
                response.sendRedirect("panel_secretaria.jsp?msg=eliminado");
            } else {
                response.sendRedirect("panel_secretaria.jsp?msg=error");
            }
        }
        
    }
}