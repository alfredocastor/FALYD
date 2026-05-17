<%@page import="com.falyd.modelo.Evento"%>
<%@page import="com.falyd.dao.EventoDAO"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.falyd.modelo.Usuario"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.YearMonth"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.util.Locale"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    HttpSession sesion = request.getSession();
    Usuario user = (Usuario) sesion.getAttribute("usuarioActual");

    if (user == null || (!user.getTipo_usuario().equals("MARED") && !user.getTipo_usuario().equals("MAESTRO"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    LocalDate hoy = LocalDate.now();
    YearMonth mesActual = YearMonth.from(hoy);
    int diasEnMes = mesActual.lengthOfMonth();
    LocalDate primerDia = mesActual.atDay(1);
    
    int diaSemanaInicio = primerDia.getDayOfWeek().getValue(); 
    int espaciosVacios = (diaSemanaInicio == 7) ? 0 : diaSemanaInicio;
    
    DateTimeFormatter formatterMes = DateTimeFormatter.ofPattern("MMMM yyyy", new Locale("es", "ES"));
    String tituloMes = mesActual.format(formatterMes);
    tituloMes = tituloMes.substring(0, 1).toUpperCase() + tituloMes.substring(1);

    EventoDAO evDAO = new EventoDAO();
    List<Evento> listaEv = evDAO.listarEventosPorMaestro(user.getId_usuario());
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Calendario - Panel del Maestro</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <style>
        :root { 
            --blue-falyd: #0b3b60; 
            --red-falyd: #d32f2f; 
            --bg-light: #f4f7fe;
            --text-main: #2b3674;
            --border-color: #e2e8f0;
        }
        body { background-color: var(--bg-light); font-family: 'Segoe UI', sans-serif; color: var(--text-main); }
        
        .sidebar { width: 260px; height: 100vh; position: fixed; background: white; border-right: none; box-shadow: 2px 0 20px rgba(0,0,0,0.04); z-index: 100; border-bottom-right-radius: 50px; }
        .nav-link { color: #8f9bba; padding: 12px 25px; font-weight: 600; margin: 4px 15px; border-radius: 10px; transition: all 0.3s; }
        .nav-link i { font-size: 1.2rem; margin-right: 12px; }
        .nav-link:hover, .nav-link.active { background-color: #e3f2fd; color: var(--blue-falyd); }
        .nav-link.text-danger { color: var(--red-falyd) !important; }
        
        .main-content { margin-left: 260px; padding: 30px 40px; padding-bottom: 60px; }
        
        .calendar-container { background: white; border-radius: 20px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); }
        .calendar-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        
        .calendar-grid { display: grid; grid-template-columns: repeat(7, 1fr); border-top: 1px solid var(--border-color); border-left: 1px solid var(--border-color); }
        .calendar-day-name { background-color: #f8fafc; text-align: center; font-weight: 700; font-size: 0.85rem; padding: 10px; border-right: 1px solid var(--border-color); border-bottom: 1px solid var(--border-color); color: #64748b; text-transform: uppercase; }
        .calendar-day { min-height: 100px; padding: 8px; border-right: 1px solid var(--border-color); border-bottom: 1px solid var(--border-color); position: relative; background-color: white; }
        .calendar-day.other-month { background-color: #f8fafc; color: #cbd5e1; }
        .day-number { font-weight: 600; font-size: 0.9rem; margin-bottom: 5px; }
        
        /* Ajuste de etiqueta dinámica */
        .event-tag { font-size: 0.7rem; font-weight: 700; padding: 4px 6px; border-radius: 6px; margin-bottom: 4px; display: block; color: white; line-height: 1.1; }
        
        .card-custom { background: white; border-radius: 20px; padding: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); border: none; margin-bottom: 20px; }
        .indicator-dot { width: 10px; height: 10px; border-radius: 50%; display: inline-block; margin-right: 8px; }
    </style>
</head>
<body>

    <div class="sidebar d-flex flex-column">
        <div class="p-4 text-center"><img src="img/Logo.png" width="120"></div>
        <nav class="nav flex-column mt-2 flex-grow-1">
            <a class="nav-link" href="panel_maestro.jsp"><i class="bi bi-house-door-fill"></i> Inicio</a>
            <a class="nav-link" href="maestro_tareas.jsp"><i class="bi bi-check2-square"></i> Tareas</a>
            <a class="nav-link active" href="maestro_calendario.jsp"><i class="bi bi-calendar3"></i> Calendario</a>
            <a class="nav-link" href="maestro_alumnos.jsp"><i class="bi bi-people-fill"></i> Alumnos</a>
            <a class="nav-link" href="maestro_calificaciones.jsp"><i class="bi bi-clipboard-data"></i> Calificaciones</a>
            <a class="nav-link" href="maestro_recursos.jsp"><i class="bi bi-book"></i> Recursos</a>
            <div class="mt-auto mb-4">
                <a class="nav-link text-danger" href="LogoutServlet"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</a>
            </div>
        </nav>
    </div>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-5">
            <div>
                <h4 class="fw-bold mb-0" style="color: var(--blue-falyd);">Sistema Web Escolar</h4>
                <h5 class="fw-bold mb-0" style="color: var(--red-falyd);">Luis Moya</h5>
                <p class="text-muted small mb-0">Panel del Maestro</p>
            </div>
            <div class="d-flex align-items-center bg-white p-2 rounded-pill shadow-sm">
                 <div class="dropdown">
                    <button class="btn btn-link text-muted p-0 me-3 position-relative" data-bs-toggle="dropdown">
                        <i class="bi bi-bell-fill fs-5"></i>
                        <span class="position-absolute top-0 start-100 translate-middle p-1 bg-danger border border-light rounded-circle"></span>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end shadow border-0" style="width: 320px; border-radius: 15px; margin-top: 15px;">
                        <li><h6 class="dropdown-header fw-bold text-dark fs-6 border-bottom pb-2">Notificaciones</h6></li>
                        <li><a class="dropdown-item py-3 border-bottom small text-wrap" href="maestro_calificaciones.jsp"><i class="bi bi-info-circle-fill text-primary me-2"></i>Recuerda calificar las tareas.</a></li>
                    </ul>
                </div>
                <img src="https://ui-avatars.com/api/?name=<%= user.getNombre() %>&background=e3f2fd&color=0b3b60" class="rounded-circle me-2" width="40">
                <div class="me-3 lh-sm">
                    <p class="mb-0 fw-bold small"><%= user.getNombre() %></p>
                    <p class="mb-0 text-muted" style="font-size: 0.75rem;">Maestro</p>
                </div>
            </div>
        </div>

        <div class="mb-4">
            <h1 class="fw-bold mb-1">Calendario</h1>
            <p class="text-muted mb-0">Consulta tus clases, tareas y evaluaciones programadas.</p>
        </div>

        <div class="row g-4">
            <div class="col-md-9">
                <div class="calendar-container">
                    <div class="calendar-header">
                        <div class="d-flex align-items-center">
                            <h3 class="fw-bold text-dark mb-0 me-3"><%= tituloMes %></h3>
                            <div class="btn-group shadow-sm">
                                <button class="btn btn-white btn-sm border"><i class="bi bi-chevron-left"></i></button>
                                <button class="btn btn-white btn-sm border fw-bold text-muted">Hoy</button>
                                <button class="btn btn-white btn-sm border"><i class="bi bi-chevron-right"></i></button>
                            </div>
                        </div>
                        <div class="d-flex align-items-center">
                            <a href="maestro_crear_evento.jsp" class="btn btn-primary btn-sm px-3 fw-bold text-decoration-none" style="background-color: var(--blue-falyd); border-radius:8px;">
                                <i class="bi bi-plus-lg me-2"></i>Crear evento
                            </a>
                        </div>
                    </div>

                    <div class="calendar-grid">
                        <div class="calendar-day-name">Dom</div><div class="calendar-day-name">Lun</div><div class="calendar-day-name">Mar</div><div class="calendar-day-name">Mié</div><div class="calendar-day-name">Jue</div><div class="calendar-day-name">Vie</div><div class="calendar-day-name">Sáb</div>

                        <% 
                        // 1. Dibujar los espacios vacíos antes de que empiece el mes
                        for(int i = 0; i < espaciosVacios; i++) { 
                        %>
                            <div class="calendar-day other-month"></div>
                        <% } %>

                        <%
                        // 2. Dibujar los días reales del mes
                        for(int dia = 1; dia <= diasEnMes; dia++) {
                            LocalDate fechaDia = mesActual.atDay(dia);
                            String fechaStr = fechaDia.toString(); // YYYY-MM-DD
                            
                            // Buscar qué eventos caen en este día específico
                            List<Evento> eventosDelDia = new ArrayList<>();
                            for(Evento e : listaEv) {
                                if(fechaStr.equals(e.getFecha_inicio())) {
                                    eventosDelDia.add(e);
                                }
                            }
                            
                            // Resaltar si es el día de "Hoy"
                            String bgDia = fechaDia.equals(hoy) ? "bg-light" : "";
                            String claseNumero = fechaDia.equals(hoy) ? "text-primary fw-bold fs-5" : "";
                        %>
                            <div class="calendar-day <%= bgDia %>">
                                <div class="day-number <%= claseNumero %>"><%= dia %></div>
                                
                                <% for(Evento e : eventosDelDia) { %>
                                    <span class="event-tag shadow-sm" style="background-color: <%= e.getColor() %>;" title="<%= e.getDescription() != null ? e.getDescription() : "" %>">
                                        <%= e.getTitulo() %>
                                        <% if(e.getHora_inicio() != null && !e.getHora_inicio().isEmpty()) { %><br><i class="bi bi-clock"></i> <%= e.getHora_inicio() %><% } %>
                                    </span>
                                <% } %>
                            </div>
                        <% } %>

                        <%
                        // 3. Rellenar los huecos al final para que la tabla quede cuadrada (múltiplo de 7)
                        int celdasTotales = espaciosVacios + diasEnMes;
                        int espaciosSobrantes = (7 - (celdasTotales % 7)) % 7;
                        for(int i = 0; i < espaciosSobrantes; i++) {
                        %>
                            <div class="calendar-day other-month"></div>
                        <% } %>
                    </div>
                    </div>
            </div>

            <div class="col-md-3">
                <div class="card-custom mb-4">
                    <h5 class="fw-bold mb-3" style="font-size: 1rem;">Tipos de eventos</h5>
                    <div class="small">
                        <p class="mb-2"><span class="indicator-dot" style="background-color: #0d47a1;"></span> Clases oficiales</p>
                        <p class="mb-2"><span class="indicator-dot" style="background-color: #c53929;"></span> Evaluaciones</p>
                        <p class="mb-2"><span class="indicator-dot" style="background-color: #137333;"></span> Entrega de tareas</p>
                        <p class="mb-0"><span class="indicator-dot" style="background-color: #d69e2e;"></span> Reuniones / Otros</p>
                    </div>
                </div>

                <div class="card-custom">
                    <h5 class="fw-bold mb-3" style="font-size: 1rem;">Agenda de eventos</h5>
                    <% if(listaEv.isEmpty()) { %>
                        <p class="text-muted small mb-0">No hay eventos guardados en la base de datos.</p>
                    <% } else {
                        for(Evento ev : listaEv) { %>
                            <div class="border-start border-3 ps-2 mb-3 shadow-sm py-1" style="border-color: <%= ev.getColor() %> !important; background-color: #f8fafc; border-radius: 0 8px 8px 0;">
                                <h6 class="fw-bold mb-1 small text-dark"><%= ev.getTitulo() %></h6>
                                <p class="text-muted mb-1" style="font-size: 0.72rem;">
                                    <i class="bi bi-calendar-event me-1"></i><%= ev.getFecha_inicio() %>
                                    <% if(ev.getHora_inicio() != null && !ev.getHora_inicio().isEmpty()) { %> 
                                        | <i class="bi bi-clock me-1"></i><%= ev.getHora_inicio() %>
                                    <% } %>
                                </p>
                            </div>
                    <% } } %>
                </div>
            </div>
        </div>
    </div>
                                            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>