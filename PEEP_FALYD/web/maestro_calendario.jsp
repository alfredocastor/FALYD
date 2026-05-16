<%@page import="com.falyd.modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    HttpSession sesion = request.getSession();
    Usuario user = (Usuario) sesion.getAttribute("usuarioActual");

    if (user == null || !user.getTipo_usuario().equals("MARED") && !user.getTipo_usuario().equals("MAESTRO")) {
        response.sendRedirect("login.jsp");
        return;
    }
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
        
        /* Sidebar */
        .sidebar { width: 260px; height: 100vh; position: fixed; background: white; border-right: none; box-shadow: 2px 0 20px rgba(0,0,0,0.04); z-index: 100; border-bottom-right-radius: 50px; }
        .nav-link { color: #8f9bba; padding: 12px 25px; font-weight: 600; margin: 4px 15px; border-radius: 10px; transition: all 0.3s; }
        .nav-link i { font-size: 1.2rem; margin-right: 12px; }
        .nav-link:hover { background-color: #f4f7fe; color: var(--blue-falyd); }
        .nav-link.active { background-color: #e3f2fd; color: var(--blue-falyd); }
        .nav-link.text-danger { color: var(--red-falyd) !important; }
        
        .main-content { margin-left: 260px; padding: 30px 40px; padding-bottom: 60px; }
        
        /* Estilos del Calendario */
        .calendar-container { background: white; border-radius: 20px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); }
        .calendar-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        
        /* Cuadrícula del Calendario */
        .calendar-grid { display: grid; grid-template-columns: repeat(7, 1fr); border-top: 1px solid var(--border-color); border-left: 1px solid var(--border-color); }
        .calendar-day-name { background-color: #f8fafc; text-align: center; font-weight: 700; font-size: 0.85rem; padding: 10px; border-right: 1px solid var(--border-color); border-bottom: 1px solid var(--border-color); color: #64748b; text-transform: uppercase; }
        .calendar-day { min-height: 90px; padding: 8px; border-right: 1px solid var(--border-color); border-bottom: 1px solid var(--border-color); position: relative; background-color: white; }
        .calendar-day.other-month { background-color: #f8fafc; color: #cbd5e1; }
        .day-number { font-weight: 600; font-size: 0.9rem; margin-bottom: 5px; }
        
        /* Etiquetas de Eventos */
        .event-tag { font-size: 0.7rem; font-weight: 700; padding: 3px 6px; border-radius: 6px; margin-bottom: 4px; display: block; text-overflow: ellipsis; overflow: hidden; white-space: nowrap; }
        .event-class { background-color: #e3f2fd; color: #0d47a1; border-left: 3px solid #0d47a1; }
        .event-eval { background-color: #fce8e6; color: #c53929; border-left: 3px solid #c53929; }
        .event-delivery { background-color: #e6f4ea; color: #137333; border-left: 3px solid #137333; }
        
        /* Paneles Laterales / Tarjetas Custom */
        .card-custom { background: white; border-radius: 20px; padding: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); border: none; margin-bottom: 20px; }
        .indicator-dot { width: 10px; height: 10px; border-radius: 50%; display: inline-block; margin-right: 8px; }
    </style>
</head>
<body>

    <div class="sidebar d-flex flex-column">
        <div class="p-4 text-center">
            <img src="img/Logo.png" alt="FALYD Logo" style="width: 120px; margin-bottom: 5px;">
        </div>
        <nav class="nav flex-column mt-2 flex-grow-1">
            <a class="nav-link" href="panel_maestro.jsp"><i class="bi bi-house-door-fill"></i> Inicio</a>
            <a class="nav-link" href="maestro_tareas.jsp"><i class="bi bi-check2-square"></i> Tareas</a>
            <a class="nav-link active" href="maestro_calendario.jsp"><i class="bi bi-calendar3"></i> Calendario</a>
            <a class="nav-link" href="maestro_alumnos.jsp"><i class="bi bi-people-fill"></i> Alumnos</a>
            <a class="nav-link" href="maestro_calificaciones.jsp"><i class="bi bi-clipboard-data"></i> Calificaciones</a>
            <a class="nav-link" href="#"><i class="bi bi-book"></i> Recursos</a>
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
                            <h3 class="fw-bold text-dark mb-0 me-3">Abril 2026</h3>
                            <div class="btn-group shadow-sm">
                                <button class="btn btn-white btn-sm border"><i class="bi bi-chevron-left"></i></button>
                                <button class="btn btn-white btn-sm border fw-bold text-muted">Hoy</button>
                                <button class="btn btn-white btn-sm border"><i class="bi bi-chevron-right"></i></button>
                            </div>
                        </div>
                        <div class="d-flex align-items-center">
                            <div class="btn-group shadow-sm me-3">
                                <button class="btn btn-white btn-sm border active fw-bold text-primary">Mes</button>
                                <button class="btn btn-white btn-sm border fw-bold text-muted">Semana</button>
                                <button class="btn btn-white btn-sm border fw-bold text-muted">Día</button>
                            </div>
                            <button class="btn btn-primary btn-sm px-3 fw-bold" style="background-color: var(--blue-falyd); border-radius:8px;">
                                <i class="bi bi-plus-lg me-2"></i>Crear evento
                            </button>
                        </div>
                    </div>

                    <div class="calendar-grid">
                        <div class="calendar-day-name">Dom</div><div class="calendar-day-name">Lun</div><div class="calendar-day-name">Mar</div><div class="calendar-day-name">Mié</div><div class="calendar-day-name">Jue</div><div class="calendar-day-name">Vie</div><div class="calendar-day-name">Sáb</div>

                        <div class="calendar-day other-month"><div class="day-number">29</div></div>
                        <div class="calendar-day other-month"><div class="day-number">30</div></div>
                        <div class="calendar-day other-month"><div class="day-number">31</div></div>
                        <div class="calendar-day"><div class="day-number">1</div><span class="event-tag event-class">Matemáticas<br>08:00</span></div>
                        <div class="calendar-day"><div class="day-number">2</div></div>
                        <div class="calendar-day"><div class="day-number">3</div><span class="event-tag event-eval">Evaluación Hist.</span></div>
                        <div class="calendar-day"><div class="day-number">4</div></div>

                        <div class="calendar-day"><div class="day-number">5</div></div>
                        <div class="calendar-day"><div class="day-number">6</div><span class="event-tag event-class">Matemáticas<br>08:00</span></div>
                        <div class="calendar-day"><div class="day-number">7</div></div>
                        <div class="calendar-day"><div class="day-number">8</div></div>
                        <div class="calendar-day"><div class="day-number">9</div><span class="event-tag event-delivery">Entrega Álgebra</span></div>
                        <div class="calendar-day"><div class="day-number">10</div></div>
                        <div class="calendar-day"><div class="day-number">11</div></div>

                        <div class="calendar-day"><div class="day-number">12</div></div>
                        <div class="calendar-day"><div class="day-number">13</div><span class="event-tag event-class">Matemáticas<br>08:00</span></div>
                        <div class="calendar-day"><div class="day-number">14</div></div>
                        <div class="calendar-day"><div class="day-number">15</div></div>
                        <div class="calendar-day bg-light"><div class="day-number text-primary fw-bold">16 ★</div><span class="event-tag event-class">Reunión Docente</span></div>
                        <div class="calendar-day"><div class="day-number">17</div></div>
                        <div class="calendar-day"><div class="day-number">18</div></div>

                        <div class="calendar-day"><div class="day-number">19</div></div>
                        <div class="calendar-day"><div class="day-number">20</div><span class="event-tag event-class">Matemáticas<br>08:00</span></div>
                        <div class="calendar-day"><div class="day-number">21</div></div>
                        <div class="calendar-day"><div class="day-number">22</div></div>
                        <div class="calendar-day"><div class="day-number">23</div></div>
                        <div class="calendar-day"><div class="day-number">24</div></div>
                        <div class="calendar-day"><div class="day-number">25</div></div>
                    </div>
                </div>
            </div>

            <div class="col-md-3">
                <div class="card-custom">
                    <h5 class="fw-bold mb-3" style="font-size: 1rem;">Tipos de eventos</h5>
                    <div class="small">
                        <p class="mb-2"><span class="indicator-dot" style="background-color: #0d47a1;"></span> Clases oficiales</p>
                        <p class="mb-2"><span class="indicator-dot" style="background-color: #c53929;"></span> Evaluaciones</p>
                        <p class="mb-0"><span class="indicator-dot" style="background-color: #137333;"></span> Entrega de tareas</p>
                    </div>
                </div>

                <div class="card-custom">
                    <h5 class="fw-bold mb-3" style="font-size: 1rem;">Próximos eventos</h5>
                    <div class="border-start border-danger border-3 ps-2 mb-3">
                        <h6 class="fw-bold mb-0 small text-dark">Evaluación de Historia</h6>
                        <p class="text-muted mb-0" style="font-size: 0.75rem;"><i class="bi bi-clock me-1"></i> 10:00 - 11:00 | 2º B</p>
                    </div>
                    <div class="border-start border-success border-3 ps-2">
                        <h6 class="fw-bold mb-0 small text-dark">Entrega: Tarea de Álgebra</h6>
                        <p class="text-muted mb-0" style="font-size: 0.75rem;"><i class="bi bi-clock me-1"></i> Hasta las 23:59 | 3º A</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>