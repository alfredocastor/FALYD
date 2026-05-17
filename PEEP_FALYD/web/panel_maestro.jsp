<%@page import="java.time.LocalDate"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.util.Locale"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.falyd.modelo.Evento"%>
<%@page import="com.falyd.dao.EventoDAO"%>
<%@page import="com.falyd.modelo.Tarea"%>
<%@page import="com.falyd.dao.TareaDAO"%>
<%@page import="com.falyd.modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    HttpSession sesion = request.getSession();
    Usuario user = (Usuario) sesion.getAttribute("usuarioActual");

    if (user == null || !user.getTipo_usuario().equals("MAESTRO")) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Fechas y lógica
    LocalDate hoy = LocalDate.now();
    DateTimeFormatter formatterText = DateTimeFormatter.ofPattern("EEEE dd 'de' MMMM 'de' yyyy", new Locale("es", "ES"));
    String fechaHoyTexto = hoy.format(formatterText);
    fechaHoyTexto = fechaHoyTexto.substring(0, 1).toUpperCase() + fechaHoyTexto.substring(1);
    String fechaHoySQL = hoy.toString();

    // Eventos
    EventoDAO evDAO = new EventoDAO();
    List<Evento> todosEventos = evDAO.listarEventosPorMaestro(user.getId_usuario());
    List<Evento> eventosHoy = new ArrayList<>();
    int eventosProximos = 0;
    for(Evento e : todosEventos) {
        if(fechaHoySQL.equals(e.getFecha_inicio())) eventosHoy.add(e);
        if(e.getFecha_inicio() != null && e.getFecha_inicio().compareTo(fechaHoySQL) >= 0) eventosProximos++;
    }

    // Tareas
    TareaDAO tDAO = new TareaDAO();
    List<Tarea> misTareas = tDAO.listarTareasPorMaestro(user.getId_usuario());
    int tareasActivas = 0;
    for(Tarea t : misTareas) {
        if(t.getFecha_entrega() != null && t.getFecha_entrega().compareTo(fechaHoySQL) >= 0) tareasActivas++;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel del Maestro - FALYD</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <style>
        :root { --blue-falyd: #0b3b60; --red-falyd: #d32f2f; --bg-light: #f4f7fe; --text-main: #2b3674; }
        body { background-color: var(--bg-light); font-family: 'Segoe UI', sans-serif; color: var(--text-main); }
        .sidebar { width: 260px; height: 100vh; position: fixed; background: white; z-index: 100; border-bottom-right-radius: 50px; }
        .nav-link { color: #8f9bba; padding: 12px 25px; font-weight: 600; margin: 4px 15px; border-radius: 10px; transition: all 0.3s; }
        .nav-link i { font-size: 1.2rem; margin-right: 12px; }
        .nav-link:hover, .nav-link.active { background-color: #e3f2fd; color: var(--blue-falyd); }
        .nav-link.text-danger { color: var(--red-falyd) !important; }
        .main-content { margin-left: 260px; padding: 30px 40px; }
        .card-custom { border-radius: 20px; border: none; box-shadow: 0 4px 15px rgba(0,0,0,0.03); background: white; padding: 20px; }
        .welcome-card { background: linear-gradient(135deg, #e3f2fd 0%, #bbdefb 100%); border-radius: 20px; padding: 30px; border: none; }
        .btn-primary-custom { background-color: var(--blue-falyd); color: white; border-radius: 10px; font-weight: 600; padding: 6px 16px; text-decoration: none;}
        .icon-box { width: 45px; height: 45px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; }
        .icon-box.blue { background-color: #e3f2fd; color: var(--blue-falyd); }
        .icon-box.red { background-color: #ffebee; color: var(--red-falyd); }
        .quick-access-btn { text-align: center; padding: 15px; border: 1px solid #e2e8f0; border-radius: 16px; transition: 0.2s; cursor: pointer; text-decoration: none; color: var(--text-main); display: block; }
        .quick-access-btn:hover { background-color: #f8fafc; border-color: #cbd5e1; transform: translateY(-3px); }
        .quick-access-btn i { font-size: 2rem; color: var(--blue-falyd); margin-bottom: 10px; display: block; }
    </style>
</head>
<body>

    <div class="sidebar d-flex flex-column">
        <div class="p-4 text-center"><img src="img/Logo.png" width="120"></div>
        <nav class="nav flex-column mt-2 flex-grow-1">
            <a class="nav-link active" href="panel_maestro.jsp"><i class="bi bi-house-door-fill"></i> Inicio</a>
            <a class="nav-link" href="maestro_tareas.jsp"><i class="bi bi-check2-square"></i> Tareas</a>
            <a class="nav-link" href="maestro_calendario.jsp"><i class="bi bi-calendar3"></i> Calendario</a>
            <a class="nav-link" href="maestro_alumnos.jsp"><i class="bi bi-people-fill"></i> Alumnos</a>
            <a class="nav-link" href="maestro_calificaciones.jsp"><i class="bi bi-clipboard-data"></i> Calificaciones</a>
            <a class="nav-link" href="maestro_recursos.jsp"><i class="bi bi-book"></i> Recursos</a>
            <a class="nav-link" href="maestro_mensajes.jsp"><i class="bi bi-chat-dots"></i> Mensajes</a>
            <div class="mt-auto mb-4">
                <a class="nav-link" href="maestro_ayuda.jsp"><i class="bi bi-question-circle"></i> Ayuda</a>
<a class="nav-link text-danger" href="#" data-bs-toggle="modal" data-bs-target="#modalCerrarSesion"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</a>            </div>
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
                   <%
    int totalAlertas = tareasActivas + eventosHoy.size(); 
%>
<button class="btn btn-link text-muted p-0 me-3 position-relative" data-bs-toggle="dropdown" aria-expanded="false">
    <i class="bi bi-bell-fill fs-5"></i>
    <% if (totalAlertas > 0) { %>
        <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger border border-light" style="font-size: 0.65rem; padding: 4px 6px;">
            <%= totalAlertas %>
        </span>
    <% } %>
</button>
                    <ul class="dropdown-menu dropdown-menu-end shadow border-0" style="width: 320px; border-radius: 15px; margin-top: 15px;">
                        <li><h6 class="dropdown-header fw-bold text-dark fs-6 border-bottom pb-2">Notificaciones</h6></li>
                        <li><a class="dropdown-item py-3 border-bottom small text-wrap" href="maestro_calificaciones.jsp"><i class="bi bi-info-circle-fill text-primary me-2"></i>Recuerda calificar las tareas.</a></li>
                    </ul>
                </div>
                <img src="https://ui-avatars.com/api/?name=<%= user.getNombre()%>&background=e3f2fd&color=0b3b60" class="rounded-circle me-2" width="40">
                <div class="me-3 lh-sm">
                    <p class="mb-0 fw-bold small"><%= user.getNombre()%></p>
                    <p class="mb-0 text-muted" style="font-size: 0.75rem;">Maestro</p>
                </div>
            </div>
        </div>

        <div class="welcome-card mb-4 d-flex justify-content-between align-items-center">
            <div>
                <h2 class="fw-bold text-dark mb-2">¡Bienvenido(a), <%= user.getNombre()%>! 👋</h2>
                <p class="text-muted mb-0">Gestiona tus tareas, alumnos y actividades académicas de forma rápida.</p>
            </div>
            <img src="https://cdn-icons-png.flaticon.com/512/3048/3048122.png" width="100" class="opacity-75">
        </div>

        <div class="row g-4 mb-4">
            <div class="col-md-6">
                <div class="card-custom h-100">
                    <h5 class="fw-bold mb-4">Agenda de hoy</h5>
                    <p class="text-muted small mb-3 text-capitalize"><%= fechaHoyTexto %></p>
                    <% if (eventosHoy.isEmpty()) { %>
                        <div class="text-center py-4"><p class="text-muted mt-2 fw-bold small">Día libre. No tienes eventos programados para hoy.</p></div>
                    <% } else { 
                        for(Evento ev : eventosHoy) { %>
                        <div class="d-flex align-items-center mb-3 p-3 border rounded-4" style="border-left: 4px solid <%= ev.getColor() %> !important;">
                            <div class="icon-box blue me-3"><i class="bi bi-calendar-event" style="color: <%= ev.getColor() %>;"></i></div>
                            <div>
                                <h6 class="fw-bold mb-1 text-dark"><%= ev.getTitulo() %></h6>
                                <p class="mb-0 small text-muted"><%= ev.getNombre_materia() %></p>
                            </div>
                        </div>
                    <% } } %>
                </div>
            </div>

            <div class="col-md-6">
                <div class="card-custom h-100">
                    <h5 class="fw-bold mb-4">Accesos rápidos</h5>
                    <div class="row g-3">
                        <div class="col-6"><a href="maestro_crear_tarea.jsp" class="quick-access-btn"><i class="bi bi-file-earmark-plus"></i><span class="fw-bold small">Crear tarea</span></a></div>
                        <div class="col-6"><a href="maestro_subir_recurso.jsp" class="quick-access-btn"><i class="bi bi-cloud-arrow-up"></i><span class="fw-bold small">Subir recurso</span></a></div>
                        <div class="col-6"><a href="maestro_alumnos.jsp" class="quick-access-btn"><i class="bi bi-people-fill"></i><span class="fw-bold small">Ver alumnos</span></a></div>
                        <div class="col-6"><a href="maestro_registrar_calificacion.jsp" class="quick-access-btn"><i class="bi bi-clipboard2-check"></i><span class="fw-bold small text-wrap">Registrar<br>calificación</span></a></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-md-7">
                <div class="card-custom h-100">
                    <h5 class="fw-bold mb-4">Últimas tareas asignadas</h5>
                    <% if (misTareas.isEmpty()) { %>
                        <div class="text-center py-4"><p class="text-muted mt-2 small">Aún no has creado ninguna tarea.</p></div>
                    <% } else { 
                        int maximo = Math.min(misTareas.size(), 3);
                        for(int i = 0; i < maximo; i++) { Tarea t = misTareas.get(i); %>
                        <div class="d-flex justify-content-between align-items-center border-bottom pb-3 mb-3">
                            <div class="d-flex align-items-center">
                                <div class="icon-box red me-3"><i class="bi bi-journal-text"></i></div>
                                <div>
                                    <h6 class="fw-bold mb-1 text-dark"><%= t.getTitulo() %></h6>
                                    <p class="mb-0 small text-muted"><%= t.getNombre_materia() %> - Cierre: <strong class="text-dark"><%= t.getFecha_entrega() %></strong></p>
                                </div>
                            </div>
                            <a href="maestro_tareas.jsp" class="btn btn-primary-custom">Revisar</a>
                        </div>
                    <% } } %>
                </div>
            </div>

            <div class="col-md-5">
                <div class="card-custom h-100">
                    <h5 class="fw-bold mb-4">Notificaciones</h5>
                    
                    <div class="d-flex align-items-start mb-4 p-2">
                        <div class="icon-box red me-3" style="width: 40px; height: 40px; font-size: 1.2rem;"><i class="bi bi-bell-fill"></i></div>
                        <div>
                            <h6 class="fw-bold mb-0 text-dark small">Tareas Activas</h6>
                            <p class="mb-0 text-muted" style="font-size: 0.8rem;">Tienes <strong><%= tareasActivas %></strong> tareas pendientes de entrega por parte de los alumnos.</p>
                        </div>
                    </div>

                    <div class="d-flex align-items-start p-2">
                        <div class="icon-box blue me-3" style="width: 40px; height: 40px; font-size: 1.2rem;"><i class="bi bi-calendar-event"></i></div>
                        <div>
                            <h6 class="fw-bold mb-0 text-dark small">Próximos Eventos</h6>
                            <p class="mb-0 text-muted" style="font-size: 0.8rem;">Tienes <strong><%= eventosProximos %></strong> eventos registrados en tu calendario a partir de hoy.</p>
                        </div>
                    </div>
                </div>
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

</body>
</html>