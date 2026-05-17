<%@page import="com.falyd.modelo.Usuario"%>
<%@page import="com.falyd.modelo.Alumno"%>
<%@page import="com.falyd.dao.AlumnoDAO"%>
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
        <title>Gestión de Alumnos - Admin FALYD</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
        <style>
            :root {
                --blue-falyd: #0b3b60;
                --red-falyd: #d32f2f;
            }
            body {
                background-color: #f0f2f5;
                font-family: 'Segoe UI', sans-serif;
            }
            .sidebar {
                width: 250px;
                height: 100vh;
                position: fixed;
                background: #1a1d20;
                color: white;
                border-right: 1px solid #333;
            }
            .nav-link {
                color: #adb5bd;
                padding: 12px 20px;
                font-weight: 500;
            }
            .nav-link:hover, .nav-link.active {
                background-color: #343a40;
                color: white;
                border-left: 4px solid var(--red-falyd);
            }
            .main-content {
                margin-left: 250px;
                padding: 30px;
            }
            .header-panel {
                background: white;
                padding: 15px 30px;
                border-bottom: 1px solid #ddd;
                margin-left: 250px;
            }
            .card-custom {
                border-radius: 15px;
                border: none;
                box-shadow: 0 4px 10px rgba(0,0,0,0.05);
            }
        </style>
    </head>
    <body>

        <div class="sidebar d-flex flex-column">
            <div class="p-4 bg-dark text-center">
                <h4 class="text-white fw-bold">Admin FALYD</h4>
            </div>
            <nav class="nav flex-column mt-3">
                <a class="nav-link" href="panel_admin.jsp"><i class="bi bi-speedometer2 me-2"></i> Dashboard</a>

                <p class="text-uppercase text-muted small ms-3 mt-3 mb-1">Gestión de Usuarios</p>
                <a class="nav-link" href="admin_maestros.jsp"><i class="bi bi-person-badge me-2"></i> Maestros</a>

                <a class="nav-link active" href="admin_alumnos.jsp"><i class="bi bi-people me-2"></i> Alumnos</a>

                <a class="nav-link" href="admin_secretarias.jsp"><i class="bi bi-person-workspace me-2"></i> Secretaría</a>

                <p class="text-uppercase text-muted small ms-3 mt-3 mb-1">Sistema</p>
                <a class="nav-link" href="admin_grupos.jsp"><i class="bi bi-journal-bookmark me-2"></i> Materias y Grupos</a>
                <a class="nav-link" href="#"><i class="bi bi-gear me-2"></i> Configuración</a>
                <hr class="border-secondary">
<a class="nav-link text-danger" href="#" data-bs-toggle="modal" data-bs-target="#modalCerrarSesion"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</a>            </nav>
        </div>

        <div class="header-panel d-flex justify-content-between align-items-center">
            <h5 class="mb-0 fw-bold" style="color: var(--blue-falyd);">Control Central del Sistema</h5>
            <div class="d-flex align-items-center">
                <div class="text-end me-3">
                    <p class="mb-0 fw-bold small"><%= user.getNombre()%></p>
                    <p class="mb-0 text-muted small">Administrador</p>
                </div>
                <img src="https://ui-avatars.com/api/?name=<%= user.getNombre()%>&background=d32f2f&color=fff" class="rounded-circle" width="40">
            </div>
        </div>

        <div class="main-content">
            <h2 class="fw-bold mb-4">Directorio General de Alumnos</h2>

            <div class="alert alert-warning border-0 shadow-sm" role="alert">
                <i class="bi bi-info-circle-fill me-2"></i><strong>Nota para el Administrador:</strong> El registro y gestión detallada de los alumnos corresponde al departamento de <strong>Secretaría</strong>. Esta vista es únicamente para auditoría y consulta global.
            </div>

            <div class="card card-custom p-4 mt-4">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h5 class="fw-bold mb-0"><i class="bi bi-people-fill me-2 text-primary"></i>Matrícula Activa</h5>
                    <a href="ReporteServlet?tipo=alumnos" class="btn btn-outline-secondary">
                        <i class="bi bi-file-earmark-pdf-fill me-2 text-danger"></i>Descargar PDF
                    </a>
                </div>

                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>ID Alumno</th>
                                <th>Nombre del Estudiante</th>
                                <th>Grupo Asignado</th>
                                <th>Estado</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                // Reutilizamos tu AlumnoDAO que ya funciona perfecto
                                AlumnoDAO aDAO = new AlumnoDAO();
                                List<Alumno> listaAlumnos = aDAO.listarAlumnos();

                                if (listaAlumnos.isEmpty()) {
                            %>
                            <tr>
                                <td colspan="4" class="text-center py-4 text-muted">No hay alumnos registrados en el sistema aún.</td>
                            </tr>
                            <%
                            } else {
                                for (Alumno a : listaAlumnos) {
                            %>
                            <tr>
                                <td><strong><%= a.getId_alumno()%></strong></td>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <img src="https://ui-avatars.com/api/?name=<%= a.getNombre()%>&background=random&color=fff" class="rounded-circle me-2" width="32">
                                        <%= a.getNombre()%>
                                    </div>
                                </td>
                                <td>
                                    <span class="badge <%= (a.getGrupo() != null && !a.getGrupo().isEmpty()) ? "bg-info text-dark" : "bg-secondary"%>">
                                        <%= (a.getGrupo() != null && !a.getGrupo().isEmpty()) ? a.getGrupo() : "Sin asignar"%>
                                    </span>
                                </td>
                                <td><span class="badge bg-success-subtle text-success border border-success-subtle">Inscrito</span></td>
                            </tr>
                            <%
                                    } // fin del for
                                } // fin del else
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