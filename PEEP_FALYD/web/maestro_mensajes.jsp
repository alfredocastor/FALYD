<%@page import="com.falyd.modelo.Mensaje"%>
<%@page import="com.falyd.dao.MensajeDAO"%>
<%@page import="com.falyd.modelo.Alumno"%>
<%@page import="com.falyd.dao.AlumnoDAO"%>
<%@page import="java.util.List"%>
<%@page import="com.falyd.modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    HttpSession sesion = request.getSession();
    Usuario user = (Usuario) sesion.getAttribute("usuarioActual");

    if (user == null || !user.getTipo_usuario().equals("MAESTRO")) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Obtenemos todos los alumnos reales para la lista de contactos
    AlumnoDAO aDAO = new AlumnoDAO();
    List<Alumno> listaAlumnos = aDAO.listarAlumnos();

    // Verificamos qué alumno seleccionó el maestro para chatear
    String idAlumnoSeleccionadoStr = request.getParameter("id_alumno");
    int idUsuarioDestino = -1;
    String nombreDestino = "Selecciona un chat";
    
    if (idAlumnoSeleccionadoStr != null) {
        idUsuarioDestino = Integer.parseInt(idAlumnoSeleccionadoStr);
        for (Alumno a : listaAlumnos) {
            if (a.getId_usuario() == idUsuarioDestino) {
                nombreDestino = a.getNombre();
                break;
            }
        }
    } else if (!listaAlumnos.isEmpty()) {
        idUsuarioDestino = listaAlumnos.get(0).getId_usuario();
        nombreDestino = listaAlumnos.get(0).getNombre();
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mensajes - Panel del Maestro</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <style>
        :root { --blue-falyd: #0b3b60; --red-falyd: #d32f2f; --bg-light: #f4f7fe; --text-main: #2b3674; --border-color: #e2e8f0; }
        /* Restauramos el body idéntico al panel de inicio */
        body { background-color: var(--bg-light); font-family: 'Segoe UI', sans-serif; color: var(--text-main); }
        
        .sidebar { width: 260px; height: 100vh; position: fixed; background: white; border-right: none; box-shadow: 2px 0 20px rgba(0,0,0,0.04); z-index: 100; border-bottom-right-radius: 50px; }
        .nav-link { color: #8f9bba; padding: 12px 25px; font-weight: 600; margin: 4px 15px; border-radius: 10px; transition: all 0.3s; text-decoration: none; display: block; }
        .nav-link i { font-size: 1.2rem; margin-right: 12px; }
        .nav-link:hover, .nav-link.active { background-color: #e3f2fd; color: var(--blue-falyd); }
        .nav-link.text-danger { color: var(--red-falyd) !important; }
        
        /* main-content idéntico al panel de inicio */
        .main-content { margin-left: 260px; padding: 30px 40px; }
        
        /* Contenedor del Chat (Adaptado para no romper el layout) */
        .chat-container { background: white; border-radius: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); display: flex; height: 75vh; overflow: hidden; border: 1px solid var(--border-color); }
        
        /* Lista Contactos */
        .contacts-list { width: 350px; border-right: 1px solid var(--border-color); display: flex; flex-direction: column; background: #fafcff; }
        .contacts-header { padding: 20px; border-bottom: 1px solid var(--border-color); background: white; }
        .contact-item { padding: 15px 20px; border-bottom: 1px solid var(--border-color); cursor: pointer; transition: 0.2s; display: flex; align-items: center; text-decoration: none; color: inherit; }
        .contact-item:hover { background-color: #f1f5f9; }
        .contact-item.active { background-color: #e3f2fd; border-left: 4px solid var(--blue-falyd); }
        .contact-avatar { width: 45px; height: 45px; border-radius: 50%; object-fit: cover; margin-right: 15px; }
        .contact-name { font-weight: 700; font-size: 0.95rem; color: var(--text-main); margin-bottom: 2px; }
        
        /* Chat Area */
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

        /* Input Enviar */
        .chat-input-area { padding: 15px 25px; border-top: 1px solid var(--border-color); background: white; display: flex; align-items: center; }
        .chat-input { background: #f1f5f9; border: none; border-radius: 20px; padding: 12px 20px; flex-grow: 1; margin: 0 15px; font-size: 0.9rem; }
        .chat-input:focus { outline: none; box-shadow: 0 0 0 2px #bbdefb; }
        .btn-send { background: var(--blue-falyd); color: white; border: none; width: 45px; height: 45px; border-radius: 50%; display: flex; justify-content: center; align-items: center; cursor: pointer; transition: 0.2s;}
        .btn-send:hover { background: #082d4a; transform: scale(1.05); }
    </style>
</head>
<body>

    <div class="sidebar d-flex flex-column">
        <div class="p-4 text-center"><img src="img/Logo.png" width="120"></div>
        <nav class="nav flex-column mt-2 flex-grow-1">
            <a class="nav-link" href="panel_maestro.jsp"><i class="bi bi-house-door-fill"></i> Inicio</a>
            <a class="nav-link" href="maestro_tareas.jsp"><i class="bi bi-check2-square"></i> Tareas</a>
            <a class="nav-link" href="maestro_calendario.jsp"><i class="bi bi-calendar3"></i> Calendario</a>
            <a class="nav-link" href="maestro_alumnos.jsp"><i class="bi bi-people-fill"></i> Alumnos</a>
            <a class="nav-link" href="maestro_calificaciones.jsp"><i class="bi bi-clipboard-data"></i> Calificaciones</a>
            <a class="nav-link" href="maestro_recursos.jsp"><i class="bi bi-book"></i> Recursos</a>
            <a class="nav-link active" href="maestro_mensajes.jsp"><i class="bi bi-chat-dots"></i> Mensajes</a>
            <div class="mt-auto mb-4">
                <a class="nav-link text-danger" href="LogoutServlet"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</a>
            </div>
        </nav>
    </div>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="fw-bold mb-0" style="color: var(--blue-falyd);">Sistema Web Escolar</h4>
                <p class="text-muted small mb-0">Panel del Maestro</p>
            </div>
            <div class="d-flex align-items-center bg-white p-2 rounded-pill shadow-sm">
                <div class="dropdown">
                    <button class="btn btn-link text-muted p-0 me-3 position-relative" data-bs-toggle="dropdown" aria-expanded="false">
                        <i class="bi bi-bell-fill fs-5"></i>
                        <span class="position-absolute top-0 start-100 translate-middle p-1 bg-danger border border-light rounded-circle"></span>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end shadow border-0" style="width: 320px; border-radius: 15px; margin-top: 15px;">
                        <li><h6 class="dropdown-header fw-bold text-dark fs-6 border-bottom pb-2">Notificaciones</h6></li>
                        <li><a class="dropdown-item py-3 border-bottom small text-wrap" href="maestro_calificaciones.jsp"><i class="bi bi-info-circle-fill text-primary me-2"></i>Recuerda calificar las tareas.</a></li>
                        <li><a class="dropdown-item py-3 small text-wrap" href="maestro_calendario.jsp"><i class="bi bi-calendar-event-fill text-warning me-2"></i>Revisa tus próximos eventos en la agenda.</a></li>
                    </ul>
                </div>
                <img src="https://ui-avatars.com/api/?name=<%= user.getNombre()%>&background=e3f2fd&color=0b3b60" class="rounded-circle me-2" width="40">
                <div class="me-3 lh-sm">
                    <p class="mb-0 fw-bold small"><%= user.getNombre()%></p>
                    <p class="mb-0 text-muted" style="font-size: 0.75rem;">Maestro</p>
                </div>
            </div>
        </div>

        <div class="d-flex justify-content-between align-items-end mb-4">
            <div>
                <h2 class="fw-bold mb-1">Mensajes</h2>
                <p class="text-muted mb-0">Comunícate con tus alumnos de forma directa.</p>
            </div>
            
        </div>

        <div class="chat-container">
            <div class="contacts-list">
                <div class="contacts-header">
                    <div class="input-group">
                        <span class="input-group-text bg-light border-end-0 rounded-start-pill"><i class="bi bi-search text-muted"></i></span>
                        <input type="text" id="buscadorContactos" class="form-control bg-light border-start-0 rounded-end-pill" placeholder="Buscar alumno..." style="font-size: 0.9rem;">
                    </div>
                </div>
                
                <div style="overflow-y: auto; flex-grow: 1;">
                    <% for(Alumno a : listaAlumnos) { 
                        boolean activo = (a.getId_usuario() == idUsuarioDestino);
                    %>
                    <a href="maestro_mensajes.jsp?id_alumno=<%= a.getId_usuario() %>" class="contact-item <%= activo ? "active" : "" %>">
                        <img src="https://ui-avatars.com/api/?name=<%= a.getNombre() %>&background=random&color=fff" class="contact-avatar">
                        <div class="flex-grow-1">
                            <h6 class="contact-name"><%= a.getNombre() %></h6>
                            <p class="mb-0 text-muted small">ID: <%= a.getId_usuario() %></p>
                        </div>
                    </a>
                    <% } %>
                </div>
            </div>

            <div class="chat-area">
                <% if (idUsuarioDestino != -1) { %>
                    <div class="chat-header">
                        <div class="d-flex align-items-center">
                            <img src="https://ui-avatars.com/api/?name=<%= nombreDestino %>&background=random&color=fff" class="contact-avatar" style="width: 40px; height: 40px;">
                            <div>
                                <h6 class="fw-bold mb-0 text-dark"><%= nombreDestino %></h6>
                                <p class="text-muted small mb-0"><span class="status-dot"></span> Conectado</p>
                            </div>
                        </div>
                    </div>

                    <div class="messages-box" id="cajaMensajes">
                        <%
                            MensajeDAO mDAO = new MensajeDAO();
                            List<Mensaje> conversacion = mDAO.obtenerConversacion(user.getId_usuario(), idUsuarioDestino);
                            
                            if (conversacion.isEmpty()) {
                        %>
                            <div class="text-center text-muted my-auto">
                                <i class="bi bi-chat-dots" style="font-size: 3rem; opacity: 0.5;"></i>
                                <p class="mt-2">Envía un mensaje para iniciar la conversación con <%= nombreDestino %>.</p>
                            </div>
                        <%
                            } else {
                                for(Mensaje m : conversacion) {
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
                        
                        <button type="button" class="btn btn-link text-muted"><i class="bi bi-paperclip fs-5"></i></button>
                        <input type="text" name="contenido" class="chat-input" placeholder="Escribe un mensaje aquí..." required autocomplete="off">
                        <button type="submit" class="btn-send"><i class="bi bi-send-fill"></i></button>
                    </form>
                    
                <% } else { %>
                    <div class="d-flex flex-column justify-content-center align-items-center h-100 bg-light text-muted">
                        <i class="bi bi-inbox fs-1"></i>
                        <p class="mt-2">No hay alumnos disponibles para chatear.</p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Bajar el scroll al último mensaje enviado
        var caja = document.getElementById("cajaMensajes");
        if(caja) { caja.scrollTop = caja.scrollHeight; }

        // Buscador para la lista de contactos
        document.addEventListener("DOMContentLoaded", function() {
            const searchInput = document.getElementById('buscadorContactos');
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