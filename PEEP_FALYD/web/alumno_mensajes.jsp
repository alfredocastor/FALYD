<%@page import="com.falyd.modelo.Mensaje"%>
<%@page import="com.falyd.dao.MensajeDAO"%>
<%@page import="com.falyd.dao.MaestroDAO"%>
<%@page import="com.falyd.modelo.Alumno"%>
<%@page import="com.falyd.dao.AlumnoDAO"%>
<%@page import="com.falyd.modelo.Tarea"%>
<%@page import="com.falyd.dao.TareaDAO"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.falyd.modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    HttpSession sesion = request.getSession();
    Usuario user = (Usuario) sesion.getAttribute("usuarioActual");

    if (user == null || !user.getTipo_usuario().equals("ALUMNO")) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 1. Datos del alumno logueado
    AlumnoDAO aDAO = new AlumnoDAO();
    Alumno miPerfil = aDAO.obtenerAlumnoPorUsuario(user.getId_usuario());
    String nombreGrupo = (miPerfil != null && miPerfil.getGrupo() != null) ? miPerfil.getGrupo() : "Sin grupo";

    // 2. Lógica de la Campanita de notificaciones (Tareas pendientes)
    TareaDAO tDAO = new TareaDAO();
List<Tarea> misTareas = tDAO.listarTareasPendientesPorAlumno(miPerfil.getId_alumno());
int tareasPendientesCount = misTareas.size();

    // 3. Obtener la lista de profesores (contactos)
    MaestroDAO maeDAO = new MaestroDAO();
    List<Usuario> listaMaestros = maeDAO.listarMaestrosContactos();

    // 4. Identificar qué chat está activo
    String idMaestroStr = request.getParameter("id_maestro_user");
    int idUsuarioDestino = -1;
    String nombreDestino = "Selecciona un profesor";
    
    if (idMaestroStr != null) {
        idUsuarioDestino = Integer.parseInt(idMaestroStr);
        for (Usuario u : listaMaestros) {
            if (u.getId_usuario() == idUsuarioDestino) {
                nombreDestino = u.getNombre();
                break;
            }
        }
    } else if (!listaMaestros.isEmpty()) {
        idUsuarioDestino = listaMaestros.get(0).getId_usuario();
        nombreDestino = listaMaestros.get(0).getNombre();
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mensajes - Panel del Alumno</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <style>
        :root { --blue-falyd: #0b3b60; --red-falyd: #d32f2f; --bg-light: #f4f7fe; --text-main: #2b3674; --border-color: #e2e8f0; }
        body { background-color: var(--bg-light); font-family: 'Segoe UI', sans-serif; color: var(--text-main); }
        
        .sidebar { width: 260px; height: 100vh; position: fixed; background: white; z-index: 100; border-right: 1px solid var(--border-color); }
        .sidebar-header { padding: 20px; text-align: center; border-bottom: 1px solid var(--border-color); margin-bottom: 15px; }
        .nav-link { color: #64748b; padding: 12px 25px; font-weight: 600; margin: 4px 15px; border-radius: 10px; transition: all 0.3s; text-decoration: none; display: block; }
        .nav-link i { font-size: 1.2rem; margin-right: 12px; }
        .nav-link:hover, .nav-link.active { background-color: #e3f2fd; color: var(--blue-falyd); }
        
        .main-content { margin-left: 260px; padding: 30px 40px; }
        
        /* Contenedor del Chat moderno */
        .chat-container { background: white; border-radius: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); display: flex; height: 72vh; overflow: hidden; border: 1px solid var(--border-color); }
        
        /* Lista de Contactos Izquierda */
        .contacts-list { width: 350px; border-right: 1px solid var(--border-color); display: flex; flex-direction: column; background: #fafcff; }
        .contacts-header { padding: 20px; border-bottom: 1px solid var(--border-color); background: white; }
        .contact-item { padding: 15px 20px; border-bottom: 1px solid var(--border-color); cursor: pointer; transition: 0.2s; display: flex; align-items: center; text-decoration: none; color: inherit; }
        .contact-item:hover { background-color: #f1f5f9; }
        .contact-item.active { background-color: #e3f2fd; border-left: 4px solid var(--blue-falyd); }
        .contact-avatar { width: 45px; height: 45px; border-radius: 50%; object-fit: cover; margin-right: 15px; }
        .contact-name { font-weight: 700; font-size: 0.95rem; color: var(--text-main); margin-bottom: 2px; }
        
        /* Caja de Chat Derecha */
        .chat-area { flex-grow: 1; display: flex; flex-direction: column; background: white; }
        .chat-header { padding: 15px 25px; border-bottom: 1px solid var(--border-color); display: flex; justify-content: space-between; align-items: center; }
        .status-dot { width: 8px; height: 8px; background-color: #22c55e; border-radius: 50%; display: inline-block; margin-right: 5px; }
        
        .messages-box { flex-grow: 1; padding: 25px; overflow-y: auto; background-color: #fcfdfe; display: flex; flex-direction: column; }
        .message { margin-bottom: 15px; max-width: 70%; display: flex; }
        .message-in { align-self: flex-start; }
        .message-out { align-self: flex-end; margin-left: auto; flex-direction: row-reverse; }
        
        .msg-bubble { padding: 12px 18px; border-radius: 15px; font-size: 0.9rem; position: relative; }
        .message-in .msg-bubble { background-color: #f1f5f9; color: #334155; border-top-left-radius: 0; margin-left: 10px; }
        .message-out .msg-bubble { background-color: var(--blue-falyd); color: white; border-top-right-radius: 0; margin-right: 10px; }
        .msg-time { font-size: 0.7rem; color: #94a3b8; margin-top: 5px; text-align: right; }
        .message-out .msg-time { color: #bbdefb; }

        .chat-input-area { padding: 15px 25px; border-top: 1px solid var(--border-color); background: white; display: flex; align-items: center; }
        .chat-input { background: #f1f5f9; border: none; border-radius: 20px; padding: 12px 20px; flex-grow: 1; margin: 0 15px; font-size: 0.9rem; }
        .chat-input:focus { outline: none; box-shadow: 0 0 0 2px #bbdefb; }
        .btn-send { background: var(--blue-falyd); color: white; border: none; width: 45px; height: 45px; border-radius: 50%; display: flex; justify-content: center; align-items: center; cursor: pointer; transition: 0.2s;}
        .btn-send:hover { background: #082d4a; transform: scale(1.05); }
    </style>
</head>
<body>

    <div class="sidebar d-flex flex-column">
        <div class="sidebar-header">
            <img src="https://ui-avatars.com/api/?name=<%= user.getNombre() %>&background=e3f2fd&color=0b3b60" class="rounded-circle mb-2" width="60">
            <h6 class="fw-bold mb-0 text-dark"><%= user.getNombre() %></h6>
            <p class="text-muted small mb-0">Grupo: <%= nombreGrupo %></p>
        </div>
        <nav class="nav flex-column flex-grow-1">
            <a class="nav-link" href="panel_alumno.jsp"><i class="bi bi-house-door-fill"></i> Inicio</a>
            <a class="nav-link" href="alumno_clases.jsp"><i class="bi bi-book-half"></i> Mis clases</a>
            <a class="nav-link" href="alumno_tareas.jsp"><i class="bi bi-check2-square"></i> Tareas</a>
            <a class="nav-link" href="alumno_calendario.jsp"><i class="bi bi-calendar3"></i> Calendario</a>
            <a class="nav-link" href="alumno_recursos.jsp"><i class="bi bi-folder2-open"></i> Recursos</a>
            <a class="nav-link" href="alumno_calificaciones.jsp"><i class="bi bi-bar-chart-fill"></i> Calificaciones</a>
            <a class="nav-link active" href="alumno_mensajes.jsp"><i class="bi bi-chat-dots"></i> Mensajes</a>
            
            <div class="mt-auto mb-4">
<a class="nav-link text-danger" href="#" data-bs-toggle="modal" data-bs-target="#modalCerrarSesion"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</a>            </div>
            </div>
        </nav>
    </div>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="fw-bold mb-0" style="color: var(--blue-falyd);">Sistema Web Escolar</h4>
                <p class="text-muted small mb-0">Panel del Alumno</p>
            </div>
            <div class="d-flex align-items-center bg-white p-2 rounded-pill shadow-sm border">
                <div class="dropdown">
                    <button class="btn btn-link text-muted p-0 me-3 position-relative" data-bs-toggle="dropdown">
                        <i class="bi bi-bell-fill fs-5"></i>
                        <% if(tareasPendientesCount > 0) { %>
                            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger border border-light" style="font-size: 0.65rem; padding: 4px 6px;">
                                <%= tareasPendientesCount %>
                            </span>
                        <% } %>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end shadow border-0" style="width: 320px; border-radius: 15px; margin-top: 15px;">
                        <li><h6 class="dropdown-header fw-bold text-dark fs-6 border-bottom pb-2">Notificaciones</h6></li>
                        <li><a class="dropdown-item py-3 small text-wrap text-muted" href="alumno_tareas.jsp"><i class="bi bi-journal-text me-2 text-primary"></i>Tienes <%= tareasPendientesCount %> tareas en curso.</a></li>
                    </ul>
                </div>
                <img src="https://ui-avatars.com/api/?name=<%= user.getNombre() %>&background=e3f2fd&color=0b3b60" class="rounded-circle me-2" width="40">
                <div class="me-2 lh-sm">
                    <p class="mb-0 fw-bold small"><%= user.getNombre() %></p>
                </div>
            </div>
        </div>

        <div class="d-flex justify-content-between align-items-end mb-4">
            <div>
                <h2 class="fw-bold mb-1">Mensajes</h2>
                <p class="text-muted mb-0">Comunícate con tus profesores de manera rápida.</p>
            </div>
        </div>

        <div class="chat-container">
            
            <div class="contacts-list">
                <div class="contacts-header">
                    <div class="input-group">
                        <span class="input-group-text bg-light border-end-0 rounded-start-pill"><i class="bi bi-search text-muted"></i></span>
                        <input type="text" id="buscadorMaestros" class="form-control bg-light border-start-0 rounded-end-pill" placeholder="Buscar profesor..." style="font-size: 0.9rem;">
                    </div>
                </div>
                
                <div style="overflow-y: auto; flex-grow: 1;">
                    <% for(Usuario u : listaMaestros) { 
                        boolean activo = (u.getId_usuario() == idUsuarioDestino);
                    %>
                    <a href="alumno_mensajes.jsp?id_maestro_user=<%= u.getId_usuario() %>" class="contact-item <%= activo ? "active" : "" %>">
                        <img src="https://ui-avatars.com/api/?name=<%= u.getNombre() %>&background=0b3b60&color=fff" class="contact-avatar">
                        <div class="flex-grow-1">
                            <h6 class="contact-name mb-0"><%= u.getNombre() %></h6>
                            <p class="mb-0 text-muted small" style="font-size:0.75rem;">Docente de la institución</p>
                        </div>
                    </a>
                    <% } %>
                </div>
            </div>

            <div class="chat-area">
                <% if (idUsuarioDestino != -1) { %>
                    <div class="chat-header">
                        <div class="d-flex align-items-center">
                            <img src="https://ui-avatars.com/api/?name=<%= nombreDestino %>&background=0b3b60&color=fff" class="contact-avatar" style="width: 40px; height: 40px;">
                            <div>
                                <h6 class="fw-bold mb-0 text-dark"><%= nombreDestino %></h6>
                                <p class="text-muted small mb-0"><span class="status-dot"></span> En línea</p>
                            </div>
                        </div>
                    </div>

                    <div class="messages-box" id="cajaMensajesAlumno">
                        <%
                            MensajeDAO mDAO = new MensajeDAO();
                            List<Mensaje> conversacion = mDAO.obtenerConversacion(user.getId_usuario(), idUsuarioDestino);
                            
                            if (conversacion.isEmpty()) {
                        %>
                            <div class="text-center text-muted my-auto">
                                <i class="bi bi-chat-left-text" style="font-size: 3rem; opacity: 0.4;"></i>
                                <p class="mt-2">Escribe un mensaje para iniciar el chat con el <%= nombreDestino %>.</p>
                            </div>
                        <%
                            } else {
                                for(Mensaje m : conversacion) {
                                    // Si el emisor soy yo (el alumno), sale azul a la derecha
                                    boolean soyYo = (m.getId_emisor() == user.getId_usuario());
                        %>
                                    <div class="message <%= soyYo ? "message-out" : "message-in" %>">
                                        <div class="msg-bubble shadow-sm">
                                            <%= m.getContenido() %>
                                            <div class="msg-time"><%= m.getFecha_envio() %> <%= soyYo ? "<i class='bi bi-check2-all'></i>" : "" %></div>
                                        </div>
                                    </div>
                        <% } } %>
                    </div>

                    <form action="MensajeServlet" method="POST" class="chat-input-area m-0">
                        <input type="hidden" name="accion" value="enviar">
                        <input type="hidden" name="id_emisor" value="<%= user.getId_usuario() %>">
                        <input type="hidden" name="id_receptor" value="<%= idUsuarioDestino %>">
                        <input type="hidden" name="origen" value="alumno"> <button type="button" class="btn btn-link text-muted"><i class="bi bi-paperclip fs-5"></i></button>
                        <input type="text" name="contenido" class="chat-input" placeholder="Escribe un mensaje para el profesor..." required autocomplete="off">
                        <button type="submit" class="btn-send"><i class="bi bi-send-fill"></i></button>
                    </form>
                    
                <% } else { %>
                    <div class="d-flex flex-column justify-content-center align-items-center h-100 bg-light text-muted">
                        <i class="bi bi-person-x fs-1"></i>
                        <p class="mt-2">No hay profesores disponibles para mensajería.</p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>
<div class="modal fade" id="modalCerrarSesion" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" style="max-width: 380px;">
            <div class="modal-content border-0 shadow" style="border-radius: 20px;">
                <div class="modal-body text-center p-4">
                    <div class="mx-auto mb-3 d-flex align-items-center justify-content-center" style="width: 75px; height: 75px; background-color: #fee2e2; border-radius: 50%; color: #ef4444; font-size: 2.2rem;">
                        <i class="bi bi-box-arrow-right"></i>
                    </div>
                    
                    <h4 class="fw-bold mb-2" style="color: var(--text-main);">¿Cerrar sesión?</h4>
                    <p class="text-muted small mb-4 px-2">Estás a punto de cerrar sesión en el sistema. Tendrás que ingresar tus credenciales nuevamente para acceder.</p>
                    
                    <div class="d-flex justify-content-center gap-3">
                        <button type="button" class="btn fw-bold px-4 py-2 flex-grow-1" data-bs-dismiss="modal" style="border: 1px solid var(--border-color); color: var(--blue-falyd); border-radius: 10px; background: white;">Cancelar</button>
                        <a href="LogoutServlet" class="btn btn-danger fw-bold px-4 py-2 flex-grow-1" style="border-radius: 10px; background-color: #e53e3e; border: none;">Cerrar sesión</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Mover el scroll al fondo de la conversación
        var caja = document.getElementById("cajaMensajesAlumno");
        if(caja) { caja.scrollTop = caja.scrollHeight; }

        // Buscador instantáneo para el panel de profesores
        document.addEventListener("DOMContentLoaded", function() {
            const searchInput = document.getElementById('buscadorMaestros');
            if(searchInput) {
                searchInput.addEventListener('input', function(e) {
                    const termino = e.target.value.toLowerCase();
                    const contactos = document.querySelectorAll('.contact-item');
                    
                    contactos.forEach(contacto => {
                        const nombre = contacto.querySelector('.contact-name').innerText.toLowerCase();
                        contacto.style.display = nombre.includes(termino) ? 'flex' : 'none';
                    });
                });
            }
        });
        
    </script>
</body>
</html>