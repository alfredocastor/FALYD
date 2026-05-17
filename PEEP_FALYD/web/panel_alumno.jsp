<%@page import="com.falyd.modelo.Usuario"%>
<%@page import="com.falyd.modelo.Alumno"%>
<%@page import="com.falyd.dao.AlumnoDAO"%>
<%@page import="com.falyd.modelo.Tarea"%>
<%@page import="com.falyd.dao.TareaDAO"%>
<%@page import="com.falyd.modelo.Evento"%>
<%@page import="com.falyd.dao.EventoDAO"%>
<%@page import="com.falyd.modelo.Materia"%>
<%@page import="com.falyd.dao.MateriaDAO"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.util.Locale"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    HttpSession sesion = request.getSession();
    Usuario user = (Usuario) sesion.getAttribute("usuarioActual");

    if (user == null || !user.getTipo_usuario().equals("ALUMNO")) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 1. Datos del alumno
    AlumnoDAO aDAO = new AlumnoDAO();
    Alumno miPerfil = aDAO.obtenerAlumnoPorUsuario(user.getId_usuario());
    int miGrupoId = (miPerfil != null) ? miPerfil.getId_grupo() : 0;
    String nombreGrupo = (miPerfil != null && miPerfil.getGrupo() != null) ? miPerfil.getGrupo() : "Sin grupo";

    // 2. Tareas dinámicas
    TareaDAO tDAO = new TareaDAO();
    List<Tarea> misTareas = tDAO.listarTareasParaAlumno();

    // 3. Fechas y Eventos Dinámicos de HOY
    LocalDate hoy = LocalDate.now();
    DateTimeFormatter formatterText = DateTimeFormatter.ofPattern("EEEE dd 'de' MMMM 'de' yyyy", new Locale("es", "ES"));
    String fechaHoyTexto = hoy.format(formatterText).substring(0, 1).toUpperCase() + hoy.format(formatterText).substring(1);
    String fechaHoySQL = hoy.toString();

    EventoDAO evDAO = new EventoDAO();
    List<Evento> todosEventos = evDAO.listarEventosGenerales();
    List<Evento> eventosHoy = new ArrayList<>();
    for(Evento e : todosEventos) {
        if(fechaHoySQL.equals(e.getFecha_inicio())) {
            eventosHoy.add(e);
        }
    }

    // 4. Clases Dinámicas
    MateriaDAO mDAO = new MateriaDAO();
    List<Materia> misClases = mDAO.listarMateriasGenerales();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel del Alumno - FALYD</title>
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
        .nav-link.text-danger { color: var(--red-falyd) !important; }
        .nav-link.text-danger:hover { background-color: #fff5f5; }
        .main-content { margin-left: 260px; padding: 30px 40px; }
        .card-custom { background: white; border-radius: 20px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); border: 1px solid #f1f5f9; height: 100%; }
        .welcome-card { background: white; border-radius: 20px; padding: 30px; border: 1px solid #f1f5f9; position: relative; overflow: hidden; }
        .subject-icon { width: 45px; height: 45px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; color: white; margin-right: 15px; }
        .btn-outline-custom { border: 1px solid var(--border-color); color: var(--text-main); border-radius: 10px; font-weight: 600; font-size: 0.85rem; padding: 5px 12px; text-decoration: none;}
        .btn-outline-custom:hover { background-color: #f8fafc; color: var(--blue-falyd); }
        .btn-action-light { background-color: #f8fafc; color: var(--blue-falyd); border: none; border-radius: 8px; font-weight: 600; font-size: 0.8rem; padding: 6px 15px; text-decoration: none;}
        .btn-action-light:hover { background-color: #e3f2fd; }
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
            <a class="nav-link active" href="panel_alumno.jsp"><i class="bi bi-house-door-fill"></i> Inicio</a>
            <a class="nav-link" href="alumno_clases.jsp"><i class="bi bi-book-half"></i> Mis clases</a>
            <a class="nav-link" href="alumno_tareas.jsp"><i class="bi bi-check2-square"></i> Tareas</a>
            <a class="nav-link" href="#"><i class="bi bi-calendar3"></i> Calendario</a>
            <a class="nav-link" href="#"><i class="bi bi-folder2-open"></i> Recursos</a>
            <a class="nav-link" href="#"><i class="bi bi-bar-chart-fill"></i> Calificaciones</a>
            <a class="nav-link" href="#"><i class="bi bi-chat-dots"></i> Mensajes</a>
            <a class="nav-link" href="#"><i class="bi bi-question-circle"></i> Ayuda</a>
            <div class="mt-auto mb-4">
                <a class="nav-link text-danger" href="LogoutServlet"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</a>
            </div>
        </nav>
    </div>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="fw-bold mb-0" style="color: var(--blue-falyd);">Sistema Web Escolar</h4>
                <h5 class="fw-bold mb-0" style="color: var(--red-falyd);">Luis Moya</h5>
                <p class="text-muted small mb-0">Panel del Alumno</p>
            </div>
            <div class="d-flex align-items-center bg-white p-2 rounded-pill shadow-sm border">
                <div class="dropdown">
                    <button class="btn btn-link text-muted p-0 me-3 position-relative" data-bs-toggle="dropdown">
                        <i class="bi bi-bell-fill fs-5"></i>
                        <% if(!misTareas.isEmpty()) { %>
                            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger border border-light" style="font-size: 0.65rem; padding: 4px 6px;">
                                <%= misTareas.size() %>
                            </span>
                        <% } %>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end shadow border-0" style="width: 320px; border-radius: 15px; margin-top: 15px;">
                        <li><h6 class="dropdown-header fw-bold text-dark fs-6 border-bottom pb-2">Notificaciones</h6></li>
                        <% if(misTareas.isEmpty()) { %>
                            <li><a class="dropdown-item py-3 small text-wrap text-muted text-center" href="#">No tienes tareas nuevas.</a></li>
                        <% } else { %>
                            <li><a class="dropdown-item py-3 small text-wrap text-muted" href="#"><i class="bi bi-journal-text me-2 text-primary"></i>Tienes <%= misTareas.size() %> tareas pendientes.</a></li>
                        <% } %>
                    </ul>
                </div>
                <img src="https://ui-avatars.com/api/?name=<%= user.getNombre() %>&background=e3f2fd&color=0b3b60" class="rounded-circle me-2" width="40">
                <div class="me-2 lh-sm">
                    <p class="mb-0 fw-bold small"><%= user.getNombre() %></p>
                    <p class="mb-0 text-muted" style="font-size: 0.75rem;">Alumno</p>
                </div>
            </div>
        </div>

        <div class="row g-4 mb-4">
            <div class="col-md-7">
                <div class="welcome-card d-flex justify-content-between align-items-center h-100 shadow-sm">
                    <div>
                        <h2 class="fw-bold text-dark mb-2">¡Bienvenido(a), <%= user.getNombre() %>! 👋</h2>
                        <p class="text-muted mb-0">Gestiona tus clases, tareas y recursos académicos.</p>
                    </div>
                    <img src="https://cdn-icons-png.flaticon.com/512/3048/3048122.png" width="130" class="opacity-75">
                </div>
            </div>
            
            <div class="col-md-5">
                <div class="card-custom">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold mb-0">Agenda de hoy</h5>
                        <a href="#" class="btn-outline-custom"><i class="bi bi-calendar4 me-1"></i> Ver calendario</a>
                    </div>
                    <p class="text-muted small mb-3 text-capitalize"><%= fechaHoyTexto %></p>
                    
                    <% if(eventosHoy.isEmpty()) { %>
                        <div class="text-center py-3">
                            <p class="text-muted mt-2 fw-bold small">Día libre. No hay eventos programados hoy.</p>
                        </div>
                    <% } else { 
                        for(Evento ev : eventosHoy) { %>
                        <div class="d-flex align-items-center mb-3 p-3 rounded-4" style="background-color: #f8fafc; border-left: 4px solid <%= ev.getColor() %>;">
                            <div class="subject-icon shadow-sm" style="background-color: <%= ev.getColor() %>;"><i class="bi bi-calendar-event"></i></div>
                            <div>
                                <h6 class="fw-bold mb-1 text-dark"><%= ev.getTitulo() %></h6>
                                <p class="mb-0 small text-muted">
                                    <% if(ev.getHora_inicio() != null && !ev.getHora_inicio().isEmpty()) { %>
                                        <i class="bi bi-clock text-danger"></i> <%= ev.getHora_inicio() %>
                                    <% } else { %>
                                        Todo el día
                                    <% } %>
                                </p>
                            </div>
                        </div>
                    <% } } %>
                </div>
            </div>
        </div>

        <div class="row g-4 mb-4">
            <div class="col-md-6">
                <div class="card-custom">
                    <h5 class="fw-bold mb-4">Mis tareas pendientes</h5>
                    
                    <% if(misTareas.isEmpty()) { %>
                        <div class="text-center py-4">
                            <i class="bi bi-check-circle text-success" style="font-size: 3rem;"></i>
                            <p class="text-muted mt-2 fw-bold small">¡Estás al día! No tienes tareas pendientes.</p>
                        </div>
                    <% } else { 
                        int limit = Math.min(misTareas.size(), 3);
                        String[] colores = {"#f59e0b", "#ef4444", "#10b981", "#3b82f6"};
                        for(int i = 0; i < limit; i++) {
                            Tarea t = misTareas.get(i);
                            String colorActual = colores[i % colores.length];
                    %>
                    <div class="d-flex justify-content-between align-items-center mb-3 pb-3 border-bottom">
                        <div class="d-flex align-items-center">
                            <div class="subject-icon shadow-sm me-3" style="background-color: #f1f5f9; color: <%= colorActual %>; width: 40px; height: 40px;"><i class="bi bi-journal-text"></i></div>
                            <div>
                                <h6 class="fw-bold mb-1 text-dark small text-truncate" style="max-width: 200px;"><%= t.getTitulo() %></h6>
                                <p class="mb-0 text-muted" style="font-size: 0.75rem;"><i class="bi bi-calendar-event me-1"></i><%= t.getFecha_entrega() %> • <%= t.getNombre_materia() %></p>
                            </div>
                        </div>
                        <a href="#" class="btn-action-light">Entregar</a>
                    </div>
                    <% } } %>
                    
                    <div class="text-center mt-4 pt-2">
                        <a href="#" class="btn btn-light w-100 fw-bold text-muted border">Ver todas <i class="bi bi-chevron-right"></i></a>
                    </div>
                </div>
            </div>

            <div class="col-md-6">
                <div class="card-custom h-100">
                    <h5 class="fw-bold mb-4">Mis clases</h5>
                    
                    <% if(misClases.isEmpty()) { %>
                        <p class="text-muted small text-center mt-4">No hay materias registradas en el sistema.</p>
                    <% } else { 
                        int limitClases = Math.min(misClases.size(), 4);
                        String[] coloresClase = {"#0d47a1", "#10b981", "#8b5cf6", "#d69e2e"};
                        String[] iconosClase = {"bi-calculator", "bi-globe-americas", "bi-translate", "bi-flask"};
                        
                        for(int i = 0; i < limitClases; i++) {
                            Materia m = misClases.get(i);
                            String cColor = coloresClase[i % coloresClase.length];
                            String cIcon = iconosClase[i % iconosClase.length];
                    %>
                    <div class="d-flex align-items-center mb-3 p-3 border rounded-4">
                        <div class="subject-icon shadow-sm" style="background-color: <%= cColor %>;"><i class="bi <%= cIcon %>"></i></div>
                        <div class="flex-grow-1">
                            <h6 class="fw-bold mb-0 text-dark"><%= m.getNombre_materia() %></h6>
                            <p class="mb-0 small text-muted"><%= m.getNombre_maestro() %></p>
                        </div>
                        <i class="bi bi-chevron-right text-muted"></i>
                    </div>
                    <% } } %>
                    
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>