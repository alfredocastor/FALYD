<%@page import="com.falyd.modelo.Usuario"%>
<%@page import="com.falyd.dao.AlumnoDAO"%>
<%@page import="com.falyd.dao.MaestroDAO"%>
<%@page import="com.falyd.dao.GrupoDAO"%>
<%@page import="com.falyd.dao.MateriaDAO"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    HttpSession sesion = request.getSession();
    Usuario user = (Usuario) sesion.getAttribute("usuarioActual");

    // Seguridad: Solo el ADMIN puede ver esta pantalla
    if (user == null || !user.getTipo_usuario().equals("ADMIN")) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Consultas reales para las métricas superiores del reporte
    AlumnoDAO aDAO = new AlumnoDAO();
    int totalAlumnos = aDAO.listarAlumnos().size();

    MaestroDAO mDAO = new MaestroDAO();
    int totalMaestros = mDAO.listarMaestros().size();

    GrupoDAO gDAO = new GrupoDAO();
    int totalGrupos = gDAO.listarGrupos().size();

    MateriaDAO matDAO = new MateriaDAO();
    int totalMaterias = matDAO.listarMateriasGenerales().size();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel de Reportes - Admin FALYD</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <style>
        :root { --blue-falyd: #0b3b60; --red-falyd: #d32f2f; --bg-light: #f4f7fe; --text-main: #2b3674; --border-color: #e2e8f0; }
        body { background-color: var(--bg-light); font-family: 'Segoe UI', sans-serif; color: var(--text-main); }
        
        /* Sidebar moderno */
        .sidebar { width: 260px; height: 100vh; position: fixed; background: white; z-index: 100; border-right: 1px solid var(--border-color); }
        .sidebar-header { padding: 20px; text-align: center; border-bottom: 1px solid var(--border-color); margin-bottom: 15px; }
        .nav-link { color: #64748b; padding: 12px 25px; font-weight: 600; margin: 4px 15px; border-radius: 10px; transition: all 0.3s; text-decoration: none; display: block; }
        .nav-link i { font-size: 1.2rem; margin-right: 12px; }
        .nav-link:hover, .nav-link.active { background-color: #e3f2fd; color: var(--blue-falyd); }
        .nav-link.text-danger { color: var(--red-falyd) !important; }
        
        .main-content { margin-left: 260px; padding: 30px 40px; }
        .card-custom { background: white; border-radius: 20px; padding: 30px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); border: 1px solid #f1f5f9; }
        
        /* Tarjetas de métricas */
        .metric-card { text-align: center; border: 1px solid var(--border-color); border-radius: 20px; padding: 20px 10px; background: white; transition: 0.2s; height: 100%; }
        .metric-card:hover { transform: translateY(-3px); box-shadow: 0 10px 20px rgba(0,0,0,0.03); }
        .metric-icon-box { width: 45px; height: 45px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.4rem; margin: 0 auto 10px auto; }

        /* Grid de Reportes Disponibles */
        .report-item-card { border: 1px solid var(--border-color); border-radius: 18px; padding: 20px; text-align: center; background: white; transition: 0.2s; height: 100%; position: relative;}
        .report-item-card:hover { border-color: var(--blue-falyd); box-shadow: 0 5px 15px rgba(0,0,0,0.02); }
        .report-item-icon { width: 50px; height: 50px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; margin: 0 auto 15px auto; }

        .table th { font-weight: 700; color: #64748b; font-size: 0.85rem; text-transform: uppercase; border-bottom: 2px solid var(--border-color); }
        .table td { color: var(--text-main); font-weight: 600; font-size: 0.95rem; padding: 12px 10px; }
    </style>
</head>
<body>

    <div class="sidebar d-flex flex-column">
        <div class="sidebar-header">
            <img src="https://ui-avatars.com/api/?name=<%= user.getNombre() %>&background=e3f2fd&color=0b3b60" class="rounded-circle mb-2" width="60">
            <h6 class="fw-bold mb-0 text-dark"><%= user.getNombre() %></h6>
            <p class="text-muted small mb-0">Administrador</p>
        </div>
        <nav class="nav flex-column flex-grow-1">
            <a class="nav-link" href="panel_admin.jsp"><i class="bi bi-house-door-fill"></i> Inicio</a>
            <a class="nav-link" href="admin_alumnos.jsp"><i class="bi bi-people-fill"></i> Gestión de Alumnos</a>
            <a class="nav-link" href="admin_maestros.jsp"><i class="bi bi-person-badge-fill"></i> Gestión de Maestros</a>
            <a class="nav-link" href="admin_secretarias.jsp"><i class="bi bi-person-workspace"></i> Gestión de Secretarías</a>
            <a class="nav-link" href="admin_materias.jsp"><i class="bi bi-journal-bookmark-fill"></i> Materias</a>
            <a class="nav-link" href="admin_grupos.jsp"><i class="bi bi-diagram-3-fill"></i> Grupos</a>
            <a class="nav-link active" href="admin_reportes.jsp"><i class="bi bi-bar-chart-fill"></i> Reportes</a>
            <div class="mt-auto mb-4">
                <a class="nav-link text-danger" href="#" data-bs-toggle="modal" data-bs-target="#modalCerrarSesion"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</a>
            </div>
        </nav>
    </div>

    <div class="main-content">
        
        <div class="d-flex justify-content-between align-items-center mb-5">
            <div>
                <h2 class="fw-bold mb-1" style="color: var(--blue-falyd);">Reportes Estadísticos</h2>
                <p class="text-muted small mb-0">Genera y consulta reportes analíticos del sistema escolar</p>
            </div>
            <div class="d-flex align-items-center bg-white p-2 rounded-pill shadow-sm border">
                <img src="https://ui-avatars.com/api/?name=<%= user.getNombre() %>&background=e3f2fd&color=0b3b60" class="rounded-circle me-2" width="40">
                <div class="me-2 lh-sm">
                    <p class="mb-0 fw-bold small"><%= user.getNombre() %></p>
                    <p class="mb-0 text-muted" style="font-size: 0.75rem;">Administrador</p>
                </div>
            </div>
        </div>

        <div class="row g-4 mb-5">
            <div class="col-md-3">
                <div class="metric-card border">
                    <div class="metric-icon-box" style="background-color: #e3f2fd; color: #1e88e5;"><i class="bi bi-people-fill"></i></div>
                    <p class="text-muted small mb-1 fw-bold">Total de Alumnos</p>
                    <h3 class="fw-bold text-primary mb-0"><%= totalAlumnos %></h3>
                </div>
            </div>
            <div class="col-md-3">
                <div class="metric-card border">
                    <div class="metric-icon-box" style="background-color: #e8f5e9; color: #43a047;"><i class="bi bi-person-badge-fill"></i></div>
                    <p class="text-muted small mb-1 fw-bold">Total de Maestros</p>
                    <h3 class="fw-bold text-success mb-0"><%= totalMaestros %></h3>
                </div>
            </div>
            <div class="col-md-3">
                <div class="metric-card border">
                    <div class="metric-icon-box" style="background-color: #fff8e1; color: #f59e0b;"><i class="bi bi-journal-bookmark-fill"></i></div>
                    <p class="text-muted small mb-1 fw-bold">Total de Materias</p>
                    <h3 class="fw-bold text-warning mb-0"><%= totalMaterias %></h3>
                </div>
            </div>
            <div class="col-md-3">
                <div class="metric-card border">
                    <div class="metric-icon-box" style="background-color: #f3e5f5; color: #8e24aa;"><i class="bi bi-diagram-3-fill"></i></div>
                    <p class="text-muted small mb-1 fw-bold">Total de Grupos</p>
                    <h3 class="fw-bold mb-0" style="color: #8e24aa;"><%= totalGrupos %></h3>
                </div>
            </div>
        </div>

        <div class="card-custom mb-5">
            <h5 class="fw-bold mb-4"><i class="bi bi-funnel-fill me-2 text-primary"></i>Generador de Reportes</h5>
            <form action="ReporteServlet" method="GET">
                <div class="row g-3 align-items-end">
                    <div class="col-md-5">
                        <label class="form-label fw-bold small text-muted">Tipo de Reporte Disponible</label>
                        <select name="tipo" class="form-select bg-light border-0 p-2.5" style="border-radius: 10px;" required>
                            <option value="" selected disabled>Selecciona el módulo a exportar...</option>
                            <option value="alumnos">Reporte Completo de Alumnos</option>
                            <option value="sistema">Reporte General del Sistema (Estadísticas)</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-bold small text-muted">Formato de Salida</label>
                        <select name="formato" class="form-select bg-light border-0 p-2.5" style="border-radius: 10px;" required>
                            <option value="PDF" selected>Documento Institucional (.pdf)</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <button type="submit" class="btn btn-primary fw-bold w-100 p-2.5 shadow-sm" style="background-color: var(--blue-falyd); border: none; border-radius: 10px;">
                            <i class="bi bi-file-earmark-pdf-fill me-2"></i>Generar y Descargar
                        </button>
                    </div>
                </div>
            </form>
        </div>

        <h5 class="fw-bold mb-3">Módulos de Reporte Directos</h5>
        <div class="row g-4 mb-5">
            
            <div class="col-md-3">
                <div class="report-item-card shadow-sm border-primary">
                    <div class="report-item-icon" style="background-color: #e3f2fd; color: #1e88e5;"><i class="bi bi-people-fill"></i></div>
                    <h6 class="fw-bold text-dark mb-1">Matrícula de Alumnos</h6>
                    <p class="text-muted small mb-3">Lista completa con ID y grupo asignado.</p>
                    <a href="ReporteServlet?tipo=alumnos" class="btn btn-sm btn-primary rounded-pill px-4 fw-bold w-100" style="background-color: var(--blue-falyd); border:none;"><i class="bi bi-download me-1"></i> Descargar PDF</a>
                </div>
            </div>
            
            <div class="col-md-3">
                <div class="report-item-card shadow-sm border-success">
                    <div class="report-item-icon" style="background-color: #e8f5e9; color: #43a047;"><i class="bi bi-pie-chart-fill"></i></div>
                    <h6 class="fw-bold text-dark mb-1">Estado del Sistema</h6>
                    <p class="text-muted small mb-3">Resumen global de todos los registros activos.</p>
                    <a href="ReporteServlet?tipo=sistema" class="btn btn-sm btn-success rounded-pill px-4 fw-bold w-100"><i class="bi bi-download me-1"></i> Descargar PDF</a>
                </div>
            </div>

            <div class="col-md-3">
                <div class="report-item-card shadow-sm bg-light text-muted" style="opacity: 0.7;">
                    <span class="badge bg-secondary position-absolute top-0 start-50 translate-middle rounded-pill"><i class="bi bi-lock-fill me-1"></i>Próximamente</span>
                    <div class="report-item-icon bg-white border" style="color: #6c757d;"><i class="bi bi-person-badge-fill"></i></div>
                    <h6 class="fw-bold mb-1">Plantilla de Maestros</h6>
                    <p class="small mb-3">Listado de docentes y materias asignadas.</p>
                    <button class="btn btn-sm btn-outline-secondary rounded-pill px-4 fw-bold w-100" disabled>No disponible</button>
                </div>
            </div>
            
            <div class="col-md-3">
                <div class="report-item-card shadow-sm bg-light text-muted" style="opacity: 0.7;">
                    <span class="badge bg-secondary position-absolute top-0 start-50 translate-middle rounded-pill"><i class="bi bi-lock-fill me-1"></i>Próximamente</span>
                    <div class="report-item-icon bg-white border" style="color: #6c757d;"><i class="bi bi-diagram-3-fill"></i></div>
                    <h6 class="fw-bold mb-1">Reporte de Grupos</h6>
                    <p class="small mb-3">Información detallada de la distribución escolar.</p>
                    <button class="btn btn-sm btn-outline-secondary rounded-pill px-4 fw-bold w-100" disabled>No disponible</button>
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