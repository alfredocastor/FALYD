<%@page import="com.falyd.modelo.Usuario"%>
<%@page import="com.falyd.modelo.Alumno"%>
<%@page import="com.falyd.dao.AlumnoDAO"%>
<%@page import="com.falyd.modelo.Tarea"%>
<%@page import="com.falyd.dao.TareaDAO"%>
<%@page import="com.falyd.modelo.Evento"%>
<%@page import="com.falyd.dao.EventoDAO"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.YearMonth"%>
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

    // 2. Traer Tareas y Eventos
    TareaDAO tDAO = new TareaDAO();
List<Tarea> misTareas = tDAO.listarTareasPendientesPorAlumno(miPerfil.getId_alumno());    
    EventoDAO evDAO = new EventoDAO();
    List<Evento> todosEventos = evDAO.listarEventosGenerales();

    // 3. Lógica del Calendario Dinámico
    LocalDate hoy = LocalDate.now();
    YearMonth mesActual = YearMonth.from(hoy);
    int diasEnMes = mesActual.lengthOfMonth();
    LocalDate primerDia = mesActual.atDay(1);
    
    int diaSemanaInicio = primerDia.getDayOfWeek().getValue(); 
    int espaciosVacios = (diaSemanaInicio == 7) ? 0 : diaSemanaInicio;
    
    DateTimeFormatter formatterMes = DateTimeFormatter.ofPattern("MMMM yyyy", new Locale("es", "ES"));
    String tituloMes = mesActual.format(formatterMes);
    tituloMes = tituloMes.substring(0, 1).toUpperCase() + tituloMes.substring(1);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Calendario - Panel del Alumno</title>
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
        
        .main-content { margin-left: 260px; padding: 30px 40px; }
        .card-custom { background: white; border-radius: 20px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); border: 1px solid #f1f5f9; margin-bottom: 24px; }
        
        /* Calendario Grid */
        .calendar-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .calendar-grid { display: grid; grid-template-columns: repeat(7, 1fr); border-top: 1px solid var(--border-color); border-left: 1px solid var(--border-color); border-radius: 12px; overflow: hidden; }
        .calendar-day-name { background-color: #fcfdfe; text-align: center; font-weight: 700; font-size: 0.85rem; padding: 15px 10px; border-right: 1px solid var(--border-color); border-bottom: 1px solid var(--border-color); color: #64748b; }
        .calendar-day { min-height: 110px; padding: 10px; border-right: 1px solid var(--border-color); border-bottom: 1px solid var(--border-color); background-color: white; text-align: center; transition: 0.2s; cursor: pointer; }
        .calendar-day:hover { background-color: #f8fafc; }
        .calendar-day.other-month { background-color: #f8fafc; color: #cbd5e1; }
        .day-number { font-weight: 600; font-size: 1rem; margin-bottom: 8px; color: var(--text-main); display: inline-block; width: 30px; height: 30px; line-height: 30px; text-align: center; border-radius: 50%; }
        .day-today { background-color: var(--blue-falyd); color: white !important; }
        
        /* Puntitos de eventos (Estilo Fig 1.3) */
        .event-dot-container { display: flex; flex-direction: column; align-items: center; gap: 4px; }
        .event-dot-item { display: flex; align-items: center; justify-content: center; font-size: 0.7rem; color: #64748b; font-weight: 600; }
        .dot { width: 8px; height: 8px; border-radius: 50%; display: inline-block; margin-right: 5px; }

        /* Lista Inferior (Próximas actividades) */
        .activity-item { padding: 15px 0; border-bottom: 1px solid var(--border-color); display: flex; justify-content: space-between; align-items: center; }
        .activity-item:last-child { border-bottom: none; }
        .activity-icon { width: 45px; height: 45px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.4rem; margin-right: 15px; color: white; }
        .badge-type { font-size: 0.75rem; padding: 5px 12px; border-radius: 20px; font-weight: 600; border: 1px solid; background: transparent; }

        /* Tarjeta de recordatorio */
        .reminder-card { background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%); border: none; border-radius: 20px; text-align: center; padding: 30px 20px; }
        .bell-icon-large { font-size: 3rem; color: #d97706; margin-bottom: 15px; }
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
            <a class="nav-link" href="alumno_tareas.jsp"><i class="bi bi-check2-square"></i> Tareas</a>
            <a class="nav-link active" href="alumno_calendario.jsp"><i class="bi bi-calendar3"></i> Calendario</a>
            <a class="nav-link" href="alumno_recursos.jsp"><i class="bi bi-folder2-open"></i> Recursos</a>
            <a class="nav-link" href="alumno_calificaciones.jsp"><i class="bi bi-bar-chart-fill"></i> Calificaciones</a>
            <div class="mt-auto mb-4">
<a class="nav-link text-danger" href="#" data-bs-toggle="modal" data-bs-target="#modalCerrarSesion"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</a>            </div>
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
                            <li><a class="dropdown-item py-3 small text-wrap text-muted" href="#"><i class="bi bi-journal-text me-2 text-primary"></i>Tienes <%= misTareas.size() %> tareas pendientes de entrega.</a></li>
                        <% } %>
                    </ul>
                </div>
                <img src="https://ui-avatars.com/api/?name=<%= user.getNombre() %>&background=e3f2fd&color=0b3b60" class="rounded-circle me-2" width="40">
                <div class="me-2 lh-sm">
                    <p class="mb-0 fw-bold small"><%= user.getNombre() %></p>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-md-8">
                <div class="card-custom">
                    <div class="calendar-header">
                        <div>
                            <h4 class="fw-bold mb-0">Calendario</h4>
                            <p class="text-muted small mb-0">Consulta tus clases, tareas y eventos importantes.</p>
                        </div>
                    </div>

                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <div class="btn-group shadow-sm">
                            <button class="btn btn-outline-secondary btn-sm active fw-bold text-primary border" style="background: #e3f2fd;">Mes</button>
                            <button class="btn btn-white btn-sm fw-bold text-muted border">Semana</button>
                            <button class="btn btn-white btn-sm fw-bold text-muted border">Día</button>
                        </div>
                        <h5 class="fw-bold mb-0 text-dark"><%= tituloMes %></h5>
                        <div class="btn-group shadow-sm">
                            <button class="btn btn-white btn-sm fw-bold text-primary border">Hoy</button>
                            <button class="btn btn-white btn-sm border"><i class="bi bi-chevron-left"></i></button>
                            <button class="btn btn-white btn-sm border"><i class="bi bi-chevron-right"></i></button>
                        </div>
                    </div>

                    <div class="calendar-grid shadow-sm">
                        <div class="calendar-day-name">Lun</div><div class="calendar-day-name">Mar</div><div class="calendar-day-name">Mié</div>
                        <div class="calendar-day-name">Jue</div><div class="calendar-day-name">Vie</div><div class="calendar-day-name">Sáb</div><div class="calendar-day-name">Dom</div>

                        <% 
                        // Dibujar huecos del mes anterior
                        int startDayIndex = (diaSemanaInicio == 0) ? 6 : diaSemanaInicio - 1; // Ajuste para que empiece en Lunes
                        for(int i = 0; i < startDayIndex; i++) { %>
                            <div class="calendar-day other-month"></div>
                        <% } %>

                        <%
                        // Dibujar los días reales
                        for(int dia = 1; dia <= diasEnMes; dia++) {
                            LocalDate fechaDia = mesActual.atDay(dia);
                            String fechaStr = fechaDia.toString();
                            
                            // Buscar eventos y tareas para este día
                            List<String[]> marcadores = new ArrayList<>();
                            
                            // 1. Tareas (Verde)
                            for(Tarea t : misTareas) {
                                if(fechaStr.equals(t.getFecha_entrega())) {
                                    marcadores.add(new String[]{"#10b981", "Entrega"});
                                }
                            }
                            // 2. Eventos (Color de la BD)
                            for(Evento e : todosEventos) {
                                if(fechaStr.equals(e.getFecha_inicio())) {
                                    String color = e.getColor() != null ? e.getColor() : "#0d47a1";
                                    String label = e.getTipo_evento().contains("Examen") ? "Examen" : "Evento";
                                    marcadores.add(new String[]{color, label});
                                }
                            }

                            String claseHoy = fechaDia.equals(hoy) ? "day-today shadow" : "";
                        %>
                            <div class="calendar-day">
                                <span class="day-number <%= claseHoy %>"><%= dia %></span>
                                <div class="event-dot-container mt-1">
                                    <% 
                                    // Mostramos máximo 2 puntitos para no saturar el cuadrito
                                    int maxDots = Math.min(marcadores.size(), 2);
                                    for(int m=0; m < maxDots; m++) { 
                                        String[] mark = marcadores.get(m);
                                    %>
                                        <div class="event-dot-item"><span class="dot" style="background-color: <%= mark[0] %>;"></span><%= mark[1] %></div>
                                    <% } 
                                    if(marcadores.size() > 2) { %>
                                        <div class="event-dot-item text-primary fw-bold" style="font-size:0.65rem;">+<%= marcadores.size() - 2 %> más</div>
                                    <% } %>
                                </div>
                            </div>
                        <% } %>

                        <%
                        // Rellenar huecos finales
                        int celdasTotales = startDayIndex + diasEnMes;
                        int espaciosSobrantes = (7 - (celdasTotales % 7)) % 7;
                        for(int i = 0; i < espaciosSobrantes; i++) { %>
                            <div class="calendar-day other-month"></div>
                        <% } %>
                    </div>
                </div>

                <div class="card-custom">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h5 class="fw-bold mb-0">Próximas actividades</h5>
                        <a href="#" class="text-decoration-none fw-bold small" style="color: var(--blue-falyd);">Ver todas las actividades <i class="bi bi-chevron-right"></i></a>
                    </div>
                    
                    <% if(misTareas.isEmpty() && todosEventos.isEmpty()) { %>
                        <p class="text-center text-muted small py-3">No hay actividades próximas en tu agenda.</p>
                    <% } else { 
                        // Muestra una mezcla (simulada) de lo que viene
                        if(!misTareas.isEmpty()) {
                            Tarea t = misTareas.get(0);
                    %>
                    <div class="activity-item">
                        <div class="d-flex align-items-center">
                            <div class="activity-icon bg-success shadow-sm"><i class="bi bi-journal-text"></i></div>
                            <div>
                                <h6 class="fw-bold mb-1 text-dark text-truncate" style="max-width: 250px;"><%= t.getTitulo() %></h6>
                                <p class="text-muted small mb-0"><%= t.getNombre_materia() %></p>
                            </div>
                        </div>
                        <div class="text-end px-3">
                            <p class="fw-bold text-dark small mb-0"><%= t.getFecha_entrega() %></p>
                            <p class="text-muted small mb-0"><i class="bi bi-clock"></i> 23:59</p>
                        </div>
                        <span class="badge-type text-success" style="border-color: #10b981;">Entrega</span>
                    </div>
                    <% } 
                       if(!todosEventos.isEmpty()) {
                           Evento e = todosEventos.get(0);
                    %>
                    <div class="activity-item">
                        <div class="d-flex align-items-center">
                            <div class="activity-icon shadow-sm" style="background-color: <%= e.getColor() %>;"><i class="bi bi-calendar-event"></i></div>
                            <div>
                                <h6 class="fw-bold mb-1 text-dark text-truncate" style="max-width: 250px;"><%= e.getTitulo() %></h6>
                                <p class="text-muted small mb-0"><%= e.getNombre_materia() %></p>
                            </div>
                        </div>
                        <div class="text-end px-3">
                            <p class="fw-bold text-dark small mb-0"><%= e.getFecha_inicio() %></p>
                            <p class="text-muted small mb-0"><i class="bi bi-clock"></i> <%= e.getHora_inicio() != null ? e.getHora_inicio() : "Todo el día" %></p>
                        </div>
                        <span class="badge-type" style="color: <%= e.getColor() %>; border-color: <%= e.getColor() %>;">Evento</span>
                    </div>
                    <% } } %>
                </div>
            </div>

            <div class="col-md-4">
                
                <div class="card-custom">
                    <h6 class="fw-bold mb-3 text-dark">Tipos de eventos</h6>
                    <div class="row g-2 mb-2">
                        <div class="col-6 d-flex align-items-center small text-muted"><span class="dot" style="background-color: #0d47a1;"></span> Clases</div>
                        <div class="col-6 d-flex align-items-center small text-muted"><span class="dot" style="background-color: #10b981;"></span> Entregas</div>
                        <div class="col-6 d-flex align-items-center small text-muted"><span class="dot" style="background-color: #ef4444;"></span> Exámenes</div>
                        <div class="col-6 d-flex align-items-center small text-muted"><span class="dot" style="background-color: #f59e0b;"></span> Proyectos</div>
                    </div>
                </div>

                <div class="reminder-card shadow-sm mt-4">
                    <div class="bell-icon-large"><i class="bi bi-bell-fill"></i></div>
                    <h5 class="fw-bold text-dark mb-2">Recordatorios</h5>
                    <p class="text-muted small mb-4" style="color: #92400e !important;">Activa las notificaciones para no olvidar tus tareas y eventos importantes.</p>
                    <button class="btn btn-outline-dark fw-bold border-2 rounded-pill px-4" style="color: #92400e; border-color: #92400e;">Ir a configuración</button>
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