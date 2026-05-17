<%@page import="com.falyd.modelo.Usuario"%>
<%@page import="com.falyd.modelo.Alumno"%>
<%@page import="com.falyd.dao.AlumnoDAO"%>
<%@page import="com.falyd.modelo.Tarea"%>
<%@page import="com.falyd.dao.TareaDAO"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.temporal.ChronoUnit"%>
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

    // 1. Obtener datos del alumno y su grupo
    AlumnoDAO aDAO = new AlumnoDAO();
    Alumno miPerfil = aDAO.obtenerAlumnoPorUsuario(user.getId_usuario());
    int miGrupoId = (miPerfil != null) ? miPerfil.getId_grupo() : 0;

    // 2. Obtener tareas de SU grupo
    TareaDAO tDAO = new TareaDAO();
    List<Tarea> misTareas = tDAO.listarTareasParaAlumno();

    // 3. Lógica matemática de fechas
    LocalDate hoy = LocalDate.now();
    List<Tarea> tareasPendientes = new ArrayList<>();
    List<Tarea> tareasAtrasadas = new ArrayList<>();
    int proximas = 0;

    for (Tarea t : misTareas) {
        if (t.getFecha_entrega() != null && !t.getFecha_entrega().isEmpty()) {
            LocalDate fechaEntrega = LocalDate.parse(t.getFecha_entrega());
            long diasRestantes = ChronoUnit.DAYS.between(hoy, fechaEntrega);

            if (diasRestantes < 0) {
                tareasAtrasadas.add(t); // Ya se pasó la fecha
            } else {
                tareasPendientes.add(t); // Aún hay tiempo
                if (diasRestantes <= 7) {
                    proximas++; // Vence en los próximos 7 días
                }
            }
        }
    }
    
    // (Fase 1: Simulamos las entregadas hasta que hagamos la tabla de entregas)
    int tareasEntregadas = 0; 
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mis Tareas - Panel del Alumno</title>
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
        .card-custom { background: white; border-radius: 20px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); border: 1px solid #f1f5f9; }
        
        /* Cajas de métricas superiores */
        .stat-card { border: 1px solid var(--border-color); border-radius: 15px; padding: 20px; display: flex; align-items: center; background: white; transition: 0.2s; height: 100%; }
        .stat-card:hover { transform: translateY(-3px); box-shadow: 0 5px 15px rgba(0,0,0,0.03); }
        .stat-icon { width: 50px; height: 50px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; margin-right: 15px; }
        
        /* Lista de Tareas */
        .task-list-item { padding: 20px; border: 1px solid var(--border-color); border-radius: 15px; margin-bottom: 15px; transition: 0.2s; background: white; }
        .task-list-item:hover { border-color: #cbd5e1; box-shadow: 0 4px 10px rgba(0,0,0,0.02); }
        .task-icon-large { width: 60px; height: 60px; border-radius: 15px; display: flex; align-items: center; justify-content: center; font-size: 2rem; color: white; margin-right: 20px; }
        
        /* Botones y Badges */
        .btn-ver { color: var(--blue-falyd); border: 1px solid var(--border-color); border-radius: 8px; font-weight: 600; padding: 6px 15px; background: transparent; transition: 0.2s; text-decoration: none;}
        .btn-ver:hover { background: #f8fafc; border-color: #cbd5e1; }
        .priority-badge { font-size: 0.75rem; font-weight: 700; padding: 4px 12px; border-radius: 20px; }
        .prio-alta { color: #dc3545; background: #ffebee; }
        .prio-media { color: #d69e2e; background: #fefcbf; }
        .prio-baja { color: #38a169; background: #c6f6d5; }
    </style>
</head>
<body>

    <div class="sidebar d-flex flex-column">
        <div class="sidebar-header">
            <img src="https://ui-avatars.com/api/?name=<%= user.getNombre() %>&background=e3f2fd&color=0b3b60" class="rounded-circle mb-2" width="60">
            <h6 class="fw-bold mb-0 text-dark"><%= user.getNombre() %></h6>
            <p class="text-muted small mb-0">Alumno</p>
        </div>
        <nav class="nav flex-column flex-grow-1">
            <a class="nav-link" href="panel_alumno.jsp"><i class="bi bi-house-door-fill"></i> Inicio</a>
            <a class="nav-link" href="alumno_clases.jsp"><i class="bi bi-book-half"></i> Mis clases</a>
            <a class="nav-link active" href="alumno_tareas.jsp"><i class="bi bi-check2-square"></i> Tareas</a>
            <a class="nav-link" href="#"><i class="bi bi-calendar3"></i> Calendario</a>
            <a class="nav-link" href="#"><i class="bi bi-folder2-open"></i> Recursos</a>
            <a class="nav-link" href="#"><i class="bi bi-bar-chart-fill"></i> Calificaciones</a>
            <div class="mt-auto mb-4">
                <a class="nav-link text-danger" href="LogoutServlet"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</a>
            </div>
        </nav>
    </div>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-5">
            <div>
                <h4 class="fw-bold mb-0" style="color: var(--blue-falyd);">Sistema Web Escolar</h4>
                <p class="text-muted small mb-0">Panel del Alumno</p>
            </div>
            <div class="d-flex align-items-center bg-white p-2 rounded-pill shadow-sm border">
                <div class="dropdown">
                    <button class="btn btn-link text-muted p-0 me-3 position-relative" data-bs-toggle="dropdown">
                        <i class="bi bi-bell-fill fs-5"></i>
                        <% if(tareasPendientes.size() > 0) { %>
                            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger border border-light" style="font-size: 0.65rem; padding: 4px 6px;">
                                <%= tareasPendientes.size() %>
                            </span>
                        <% } %>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end shadow border-0" style="width: 320px; border-radius: 15px; margin-top: 15px;">
                        <li><h6 class="dropdown-header fw-bold text-dark fs-6 border-bottom pb-2">Notificaciones</h6></li>
                        <li><a class="dropdown-item py-3 small text-wrap text-muted" href="#"><i class="bi bi-journal-text me-2 text-primary"></i>Tienes <%= tareasPendientes.size() %> tareas pendientes.</a></li>
                    </ul>
                </div>
                <img src="https://ui-avatars.com/api/?name=<%= user.getNombre() %>&background=e3f2fd&color=0b3b60" class="rounded-circle me-2" width="40">
                <div class="me-2 lh-sm">
                    <p class="mb-0 fw-bold small"><%= user.getNombre() %></p>
                </div>
            </div>
        </div>

        <div class="mb-4">
            <h1 class="fw-bold mb-1">Mis tareas</h1>
            <p class="text-muted mb-0">Consulta tus tareas pendientes, entregadas y próximas.</p>
        </div>

        <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-2">
            <ul class="nav nav-pills" style="gap: 10px;">
                <li class="nav-item">
                    <a class="nav-link active rounded-pill px-4" style="background-color: var(--blue-falyd);" href="#">Pendientes <span class="badge bg-white text-dark ms-2"><%= tareasPendientes.size() %></span></a>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-muted fw-bold rounded-pill px-4" href="#">Entregadas <span class="badge bg-light text-muted ms-2"><%= tareasEntregadas %></span></a>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-muted fw-bold rounded-pill px-4" href="#">Todas <span class="badge bg-light text-muted ms-2"><%= misTareas.size() %></span></a>
                </li>
            </ul>
            
            <div class="input-group w-auto">
                <span class="input-group-text bg-white border-end-0 text-muted rounded-start-pill"><i class="bi bi-filter"></i></span>
                <select class="form-select border-start-0 rounded-end-pill text-muted fw-bold" style="width: 200px;">
                    <option selected>Filtrar por materia</option>
                </select>
            </div>
        </div>

        <div class="row g-4 mb-5">
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon" style="background-color: #fff8e1; color: #f59e0b;"><i class="bi bi-clipboard"></i></div>
                    <div>
                        <h4 class="fw-bold mb-0 text-dark"><%= tareasPendientes.size() %></h4>
                        <p class="text-muted small mb-0 lh-sm">Tareas por entregar</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon" style="background-color: #e8f5e9; color: #10b981;"><i class="bi bi-check-circle"></i></div>
                    <div>
                        <h4 class="fw-bold mb-0 text-dark"><%= tareasEntregadas %></h4>
                        <p class="text-muted small mb-0 lh-sm">Tareas completadas</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon" style="background-color: #f3e5f5; color: #8b5cf6;"><i class="bi bi-clock-history"></i></div>
                    <div>
                        <h4 class="fw-bold mb-0 text-dark"><%= proximas %></h4>
                        <p class="text-muted small mb-0 lh-sm">Entrega en próximos 7 días</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card" style="<%= (tareasAtrasadas.size() > 0) ? "border-color: #fca5a5; background-color: #fef2f2;" : "" %>">
                    <div class="stat-icon" style="background-color: #ffebee; color: #ef4444;"><i class="bi bi-calendar-x"></i></div>
                    <div>
                        <h4 class="fw-bold mb-0 <%= (tareasAtrasadas.size() > 0) ? "text-danger" : "text-dark" %>"><%= tareasAtrasadas.size() %></h4>
                        <p class="<%= (tareasAtrasadas.size() > 0) ? "text-danger" : "text-muted" %> small mb-0 lh-sm">Tareas vencidas</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-md-12">
                <div class="card-custom">
                    <div class="d-flex justify-content-between align-items-center mb-4 pb-2 border-bottom">
                        <h5 class="fw-bold mb-0">Lista de tareas pendientes</h5>
                        <div class="text-muted small fw-bold">
                            <span class="me-4">Fecha de entrega <i class="bi bi-chevron-down"></i></span>
                            <span>Prioridad <i class="bi bi-chevron-down"></i></span>
                        </div>
                    </div>

                    <% if(tareasPendientes.isEmpty()) { %>
                        <div class="text-center py-5">
                            <i class="bi bi-check2-circle text-success" style="font-size: 4rem;"></i>
                            <h5 class="fw-bold mt-3 text-dark">¡Felicidades!</h5>
                            <p class="text-muted">Estás al día con todas tus tareas y proyectos.</p>
                        </div>
                    <% } else { 
                        // Rotación de colores para diseño
                        String[] bgColors = {"#3b82f6", "#ef4444", "#10b981", "#f59e0b"};
                        String[] icons = {"bi-plus-slash-minus", "bi-book", "bi-pencil-square", "bi-flask"};
                        int index = 0;
                        
                        for (Tarea t : tareasPendientes) {
                            LocalDate fechaEntrega = LocalDate.parse(t.getFecha_entrega());
                            long dias = ChronoUnit.DAYS.between(hoy, fechaEntrega);
                            
                            // Determinar prioridad por días restantes
                            String prioridadTexto = "Baja"; String clasePrio = "prio-baja";
                            if(dias <= 2) { prioridadTexto = "Alta"; clasePrio = "prio-alta"; }
                            else if (dias <= 5) { prioridadTexto = "Media"; clasePrio = "prio-media"; }
                    %>
                    <div class="task-list-item d-flex align-items-center">
                        <div class="task-icon-large shadow-sm" style="background-color: <%= bgColors[index % 4] %>;"><i class="bi <%= icons[index % 4] %>"></i></div>
                        <div class="flex-grow-1 border-end pe-4 me-4">
                            <h5 class="fw-bold mb-1 text-dark"><%= t.getTitulo() %></h5>
                            <p class="text-muted small mb-1"><%= t.getNombre_materia() %> • <%= t.getDescripcion() %></p>
                        </div>
                        <div class="text-center border-end pe-4 me-4" style="width: 150px;">
                            <p class="mb-0 fw-bold text-dark"><i class="bi bi-calendar-event me-2"></i><%= t.getFecha_entrega() %></p>
                            <p class="mb-0 small text-danger fw-bold">(<%= dias %> días restantes)</p>
                        </div>
                        <div class="text-center border-end pe-4 me-4" style="width: 100px;">
                            <span class="priority-badge <%= clasePrio %>"><%= prioridadTexto %></span>
                        </div>
                        <div class="text-center" style="width: 120px;">
                            <a href="#" class="btn-ver w-100 d-block">Ver detalles</a>
                        </div>
                    </div>
                    <% index++; } } %>

                    <% if(!tareasAtrasadas.isEmpty()) { %>
                        <h5 class="fw-bold mb-4 mt-5 text-danger border-bottom pb-2 border-danger">Tareas atrasadas</h5>
                        
                        <% for (Tarea t : tareasAtrasadas) { 
                            LocalDate fechaEntrega = LocalDate.parse(t.getFecha_entrega());
                            long dias = ChronoUnit.DAYS.between(fechaEntrega, hoy); // Días que pasaron desde la entrega
                        %>
                        <div class="task-list-item d-flex align-items-center" style="background-color: #fff5f5; border-color: #fed7d7;">
                            <div class="task-icon-large shadow-sm" style="background-color: #8b5cf6;"><i class="bi bi-easel"></i></div>
                            <div class="flex-grow-1 border-end border-danger pe-4 me-4">
                                <h5 class="fw-bold mb-1 text-dark"><%= t.getTitulo() %></h5>
                                <p class="text-muted small mb-1"><%= t.getNombre_materia() %> • <%= t.getDescripcion() %></p>
                            </div>
                            <div class="text-center border-end border-danger pe-4 me-4" style="width: 150px;">
                                <p class="mb-0 fw-bold text-dark"><i class="bi bi-calendar-x me-2 text-danger"></i><%= t.getFecha_entrega() %></p>
                                <p class="mb-0 small text-danger fw-bold">(<%= dias %> días de retraso)</p>
                            </div>
                            <div class="text-center border-end border-danger pe-4 me-4" style="width: 100px;">
                                <span class="priority-badge prio-alta">Atrasada</span>
                            </div>
                            <div class="text-center" style="width: 120px;">
                                <a href="#" class="btn-ver w-100 d-block" style="border-color: #dc3545; color: #dc3545;">Ver detalles</a>
                            </div>
                        </div>
                        <% } %>
                    <% } %>

                    <div class="d-flex align-items-center justify-content-between bg-light p-3 rounded-4 mt-4 border">
                        <div class="d-flex align-items-center">
                            <div class="icon-box" style="background-color: #e3f2fd; color: var(--blue-falyd); width: 35px; height: 35px; font-size: 1rem; margin-right: 15px; border-radius: 50%;"><i class="bi bi-info"></i></div>
                            <p class="mb-0 text-muted small fw-bold">¿Necesitas ayuda con alguna tarea? Contacta a tu profesor(a) a través de Mensajes.</p>
                        </div>
                        <a href="alumno_mensajes.jsp" class="btn btn-outline-custom text-primary border-primary bg-white"><i class="bi bi-chat-dots me-1"></i> Ir a mensajes</a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>