/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.falyd.controlador;

import com.falyd.dao.EventoDAO;
import com.falyd.modelo.Evento;
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
public class EventoServlet extends HttpServlet {
@Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("accion");
        EventoDAO dao = new EventoDAO();

        if ("crear".equals(action)) {
            Evento ev = new Evento();
            ev.setTitulo(request.getParameter("titulo"));
            ev.setTipo_evento(request.getParameter("tipo_evento"));
            ev.setDescription(request.getParameter("descripcion"));
            ev.setColor(request.getParameter("color"));
            ev.setFecha_inicio(request.getParameter("fecha_inicio"));
            ev.setHora_inicio(request.getParameter("hora_inicio"));
            ev.setFecha_fin(request.getParameter("fecha_fin"));
            ev.setHora_fin(request.getParameter("hora_fin"));
            ev.setTodo_el_dia(request.getParameter("todo_el_dia") != null);
            
            String idMatStr = request.getParameter("id_materia");
            ev.setId_materia((idMatStr != null && !idMatStr.isEmpty()) ? Integer.parseInt(idMatStr) : 0);
            
            int idUsuario = Integer.parseInt(request.getParameter("id_usuario_maestro"));

            if (dao.registrarEvento(ev, idUsuario)) {
                response.sendRedirect("maestro_calendario.jsp?msg=exito");
            } else {
                response.sendRedirect("maestro_crear_evento.jsp?msg=error");
            }
        }
    }
}
