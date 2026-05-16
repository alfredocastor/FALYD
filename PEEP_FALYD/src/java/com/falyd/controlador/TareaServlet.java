/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.falyd.controlador;

import com.falyd.dao.TareaDAO;
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
public class TareaServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        TareaDAO dao = new TareaDAO();

        if ("crear".equals(accion)) {
            String titulo = request.getParameter("titulo");
            String descripcion = request.getParameter("descripcion");
            String fecha_entrega = request.getParameter("fecha_entrega");
            
            int id_materia = Integer.parseInt(request.getParameter("id_materia"));
            int id_usuario_maestro = Integer.parseInt(request.getParameter("id_usuario_maestro"));

            if (dao.registrarTarea(titulo, descripcion, fecha_entrega, id_usuario_maestro, id_materia)) {
                // Si se guardó, regresamos a la lista de tareas
                response.sendRedirect("maestro_tareas.jsp?msg=exito");
            } else {
                // Si falló, nos quedamos en el formulario
                response.sendRedirect("maestro_crear_tarea.jsp?msg=error");
            }
        }
    }
}
