<%@page import="com.falyd.modelo.Usuario"%>
<%@page import="com.falyd.modelo.Materia"%>
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
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Consulta de Materias - Admin FALYD</title>
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
        .card-custom { background: white; border-radius: 20px; padding: 35px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); border: 1px solid #f1f5f9; }
        
        .table th { font-weight: 700; color: #64748b; font-size: 0.85rem; text-transform: uppercase; border-bottom: 2px solid var(--border-color); }
        .table td { color: var(--text-main); font-weight: 600; font-size: 0.95rem; padding: 15px 10px; }
        
        .subject-icon-box { width: 35px; height: 35px; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: white; font-size: 1.1rem; }
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
            <a class="nav-link active" href="admin_materias.jsp"><i class="bi bi-journal-bookmark-fill"></i> Materias</a>
            <a class="nav-link" href="admin_grupos.jsp"><i class="bi bi-diagram-3-fill"></i> Grupos</a>
            <a class="nav-link" href="admin_reportes.jsp"><i class="bi bi-bar-chart-fill"></i> Reportes</a>
            <div class="mt-auto mb-4">
                <a class="nav-link text-danger" href="#" data-bs-toggle="modal" data-bs-target="#modalCerrarSesion"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</a>
            </div>
        </nav>
    </div>

    <div class="main-content">
        
        <div class="d-flex justify-content-between align-items-center mb-5">
            <div>
                <h2 class="fw-bold mb-1" style="color: var(--blue-falyd);">Consulta de Materias</h2>
                <p class="text-muted small mb-0">Catálogo global de asignaturas registradas en el sistema</p>
            </div>
            <div class="d-flex align-items-center bg-white p-2 rounded-pill shadow-sm border">
                <img src="https://ui-avatars.com/api/?name=<%= user.getNombre() %>&background=e3f2fd&color=0b3b60" class="rounded-circle me-2" width="40">
                <div class="me-2 lh-sm">
                    <p class="mb-0 fw-bold small"><%= user.getNombre() %></p>
                    <p class="mb-0 text-muted" style="font-size: 0.75rem;">Administrador</p>
                </div>
            </div>
        </div>

        <div class="alert alert-info border-0 shadow-sm rounded-4 mb-4 d-flex align-items-center" role="alert" style="background-color: #e3f2fd; color: var(--blue-falyd);">
            <i class="bi bi-info-circle-fill fs-4 me-3"></i>
            <div>
                <strong class="d-block">Vista de Auditoría (Solo Lectura)</strong>
                De acuerdo al flujo de trabajo, la creación, edición o eliminación de asignaturas corresponde al departamento de <strong>Secretaría</strong>.
            </div>
        </div>

        <div class="card-custom">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h5 class="fw-bold mb-0"><i class="bi bi-journal-text me-2 text-primary"></i>Plan de Estudios Vigente</h5>
                <span class="badge bg-secondary-subtle text-secondary border px-3 py-1.5 rounded-pill fw-bold small">Modo de consulta</span>
            </div>
            
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead>
                        <tr>
                            <th style="width: 120px;">Código</th>
                            <th>Nombre de la Materia</th>
                            <th>Nivel / Grado</th>
                            <th>Estado</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            MateriaDAO mDAO = new MateriaDAO();
                            List<Materia> listaMaterias = mDAO.listarMateriasGenerales();
                            
                            if(listaMaterias.isEmpty()){
                        %>
                            <tr>
                                <td colspan="4" class="text-center py-4 text-muted fw-bold">No hay materias dadas de alta en el sistema todavía.</td>
                            </tr>
                        <%
                            } else {
                                String[] coloresIcono = {"#0d47a1", "#10b981", "#8b5cf6", "#f59e0b"};
                                int index = 0;
                                for (Materia mat : listaMaterias) {
                                    String colorActual = coloresIcono[index % coloresIcono.length];
                        %>
                        <tr>
                            <td><span class="badge bg-light text-dark border px-2.5 py-1.5 fw-bold">MAT-0<%= index + 1 %></span></td>
                            <td>
                                <div class="d-flex align-items-center">
                                    <div class="subject-icon-box me-3" style="background-color: <%= colorActual %>;">
                                        <i class="bi bi-book-half"></i>
                                    </div>
                                    <span class="text-dark fw-bold"><%= mat.getNombre_materia() %></span>
                                </div>
                            </td>
                            <td class="text-muted"><%= (mat.getNombre_maestro() != null) ? "Asignada" : "Sin asignar" %></td>
                            <td><span class="badge bg-success-subtle text-success border border-success-subtle px-3 py-1.5">Activa</span></td>
                        </tr>
                        <% 
                                    index++;
                                } 
                            } 
                        %>
                    </tbody>
                </table>
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