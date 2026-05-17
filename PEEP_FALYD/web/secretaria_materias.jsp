<%@page import="com.falyd.modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.falyd.modelo.Materia"%>
<%@page import="com.falyd.dao.MateriaDAO"%>
<%@page import="com.falyd.modelo.Maestro"%>
<%@page import="com.falyd.dao.MaestroDAO"%>
<%
    HttpSession sesion = request.getSession();
    Usuario user = (Usuario) sesion.getAttribute("usuarioActual");

    if (user == null || !user.getTipo_usuario().equals("SECRETARIA")) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Asignar Materias - FALYD</title>
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
                background: white;
                border-right: 1px solid #ddd;
            }
            .nav-link {
                color: #555;
                padding: 12px 20px;
                font-weight: 500;
                border-left: 4px solid transparent;
            }
            .nav-link:hover, .nav-link.active {
                background-color: #e9ecef;
                color: var(--blue-falyd);
                border-left: 4px solid var(--blue-falyd);
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
            <div class="p-4">
                <img src="img/Logo.png" alt="Logo" style="width: 120px;">
            </div>
            <nav class="nav flex-column mt-2">
                <a class="nav-link" href="panel_secretaria.jsp"><i class="bi bi-card-list me-2"></i> Directorio de Alumnos</a>
                <a class="nav-link active" href="secretaria_materias.jsp"><i class="bi bi-journal-bookmark me-2"></i> Asignar Materias</a>
                <hr>
<a class="nav-link text-danger" href="#" data-bs-toggle="modal" data-bs-target="#modalCerrarSesion"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</a>            </nav>
        </div>

        <div class="header-panel d-flex justify-content-between align-items-center">
            <h5 class="mb-0 fw-bold" style="color: var(--blue-falyd);">Departamento de Control Escolar</h5>
            <div class="d-flex align-items-center">
                <div class="text-end me-3">
                    <p class="mb-0 fw-bold small"><%= user.getNombre()%></p>
                    <p class="mb-0 text-muted small">Secretaría</p>
                </div>
                <img src="https://ui-avatars.com/api/?name=<%= user.getNombre()%>&background=0b3b60&color=fff" class="rounded-circle" width="40">
            </div>
        </div>

        <div class="main-content">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2 class="fw-bold">Gestión de Materias</h2>
                <button class="btn btn-falyd" style="background-color: var(--blue-falyd); color: white;" data-bs-toggle="modal" data-bs-target="#modalNuevaMateria">
                    <i class="bi bi-plus-lg me-2"></i>Asignar Nueva Materia
                </button>
            </div>

            <div class="card card-custom p-4">
                <h5 class="fw-bold mb-4">Materias Oficiales y Maestros Asignados</h5>
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>ID Materia</th>
                                <th>Nombre de la Materia</th>
                                <th>Maestro Titular</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                // 1. Traemos la lista de materias
                                MateriaDAO matDAO = new MateriaDAO();
                                List<Materia> listaMaterias = matDAO.listarMaterias();

                                // 2. Traemos la lista de maestros UNA SOLA VEZ para usarla en todos los formularios
                                MaestroDAO maestroDAO = new MaestroDAO();
                                List<Maestro> listaMaestros = maestroDAO.listarMaestros();

                                for (Materia mat : listaMaterias) {
                            %>
                            <tr>
                                <td><strong><%= mat.getId_materia()%></strong></td>
                                <td><%= mat.getNombre_materia()%></td>
                                <td><i class="bi bi-person-video3 text-muted me-2"></i> <%= mat.getNombre_maestro()%></td>
                                <td>
                                    <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#modalEditarMat<%= mat.getId_materia() %>">
                                        <i class="bi bi-pencil"></i> Editar
                                    </button>
                                    <button class="btn btn-sm btn-outline-danger ms-1" data-bs-toggle="modal" data-bs-target="#modalEliminarMat<%= mat.getId_materia() %>">
                                        <i class="bi bi-trash"></i> Quitar
                                    </button>
                                </td>
                            </tr>

                            <div class="modal fade" id="modalEliminarMat<%= mat.getId_materia() %>" tabindex="-1" aria-hidden="true">
                                <div class="modal-dialog modal-dialog-centered">
                                    <div class="modal-content border-0 shadow">
                                        <div class="modal-header bg-danger text-white">
                                            <h5 class="modal-title fw-bold"><i class="bi bi-exclamation-triangle-fill me-2"></i>Eliminar Materia</h5>
                                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <form action="MateriaServlet" method="POST">
                                            <div class="modal-body p-4 text-center">
                                                <input type="hidden" name="accion" value="eliminar">
                                                <input type="hidden" name="id_materia" value="<%= mat.getId_materia() %>">
                                                <i class="bi bi-trash text-danger mb-3" style="font-size: 3rem;"></i>
                                                <p class="fs-5 mb-1">¿Borrar la materia <br><strong><%= mat.getNombre_materia() %></strong>?</p>
                                                <p class="text-muted small">El maestro ya no la tendrá asignada.</p>
                                            </div>
                                            <div class="modal-footer bg-light justify-content-center">
                                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                                                <button type="submit" class="btn btn-danger">Sí, borrar materia</button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>

                            <div class="modal fade" id="modalEditarMat<%= mat.getId_materia() %>" tabindex="-1" aria-hidden="true">
                                <div class="modal-dialog modal-dialog-centered">
                                    <div class="modal-content border-0 shadow">
                                        <div class="modal-header bg-primary text-white">
                                            <h5 class="modal-title fw-bold"><i class="bi bi-pencil-square me-2"></i>Editar Materia</h5>
                                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <form action="MateriaServlet" method="POST">
                                            <div class="modal-body p-4">
                                                <input type="hidden" name="accion" value="editar">
                                                <input type="hidden" name="id_materia" value="<%= mat.getId_materia() %>">
                                                
                                                <div class="mb-3">
                                                    <label class="form-label fw-bold small text-muted">Nombre de la Materia</label>
                                                    <input type="text" class="form-control" name="nombre_materia" value="<%= mat.getNombre_materia() %>" required>
                                                </div>
                                                
                                                <div class="mb-3">
                                                    <label class="form-label fw-bold small text-muted">Reasignar Maestro</label>
                                                    <select class="form-select" name="id_maestro" required>
                                                        <% for (Maestro prof : listaMaestros) { %>
                                                            <option value="<%= prof.getId_maestro() %>" <%= mat.getId_maestro() == prof.getId_maestro() ? "selected" : "" %>>
                                                                Prof. <%= prof.getNombre() %>
                                                            </option>
                                                        <% } %>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="modal-footer bg-light">
                                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                                                <button type="submit" class="btn btn-primary">Actualizar Cambios</button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>

                            <%
                                } // Fin del ciclo
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div class="modal fade" id="modalNuevaMateria" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content border-0 shadow">
                    <div class="modal-header" style="background-color: var(--blue-falyd); color: white;">
                        <h5 class="modal-title fw-bold"><i class="bi bi-journal-plus me-2"></i>Asignar Nueva Materia</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="MateriaServlet" method="POST">
                        <div class="modal-body p-4">
                            <input type="hidden" name="accion" value="agregar">

                            <div class="mb-3">
                                <label class="form-label fw-bold small text-muted">Nombre de la Materia</label>
                                <input type="text" class="form-control" name="nombre_materia" placeholder="Ej. Español 2º B" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold small text-muted">Asignar a Maestro</label>
                                <select class="form-select" name="id_maestro" required>
                                    <option value="" selected disabled>Selecciona un maestro...</option>
                                    <%
                                        // Reciclamos la variable listaMaestros que declaramos arriba de la tabla
                                        for (Maestro prof : listaMaestros) {
                                    %>
                                        <option value="<%= prof.getId_maestro() %>">
                                            Prof. <%= prof.getNombre() %>
                                        </option>
                                    <%
                                        }
                                    %>
                                </select>
                            </div>
                        </div>
                        <div class="modal-footer bg-light">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                            <button type="submit" class="btn btn-falyd" style="background-color: var(--blue-falyd); color: white;">Guardar Materia</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
<a class="nav-link text-danger" href="#" data-bs-toggle="modal" data-bs-target="#modalCerrarSesion"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</a>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>