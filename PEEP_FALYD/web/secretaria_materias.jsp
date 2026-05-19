<%@page import="com.falyd.dao.GrupoDAO"%> 
<%@page import="com.falyd.modelo.Grupo"%>
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

    // Seguridad: Solo SECRETARIA puede entrar aquí
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
        <title>Asignar Materias - Secretaría FALYD</title>
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
            body {
                background-color: var(--bg-light);
                font-family: 'Segoe UI', sans-serif;
                color: var(--text-main);
            }

            /* Sidebar moderno */
            .sidebar {
                width: 260px;
                height: 100vh;
                position: fixed;
                background: white;
                z-index: 100;
                border-right: 1px solid var(--border-color);
            }
            .sidebar-header {
                padding: 20px;
                text-align: center;
                border-bottom: 1px solid var(--border-color);
                margin-bottom: 15px;
            }
            .nav-link {
                color: #64748b;
                padding: 12px 25px;
                font-weight: 600;
                margin: 4px 15px;
                border-radius: 10px;
                transition: all 0.3s;
                text-decoration: none;
                display: block;
            }
            .nav-link i {
                font-size: 1.2rem;
                margin-right: 12px;
            }
            .nav-link:hover, .nav-link.active {
                background-color: #e3f2fd;
                color: var(--blue-falyd);
            }
            .nav-link.text-danger {
                color: var(--red-falyd) !important;
            }

            .main-content {
                margin-left: 260px;
                padding: 30px 40px;
            }
            .card-custom {
                background: white;
                border-radius: 20px;
                padding: 35px;
                box-shadow: 0 4px 15px rgba(0,0,0,0.02);
                border: 1px solid #f1f5f9;
            }

            /* Tarjetas de métricas */
            .metric-card {
                text-align: center;
                border: 1px solid var(--border-color);
                border-radius: 20px;
                padding: 20px 10px;
                background: white;
                transition: 0.2s;
                height: 100%;
            }
            .metric-card:hover {
                transform: translateY(-3px);
                box-shadow: 0 10px 20px rgba(0,0,0,0.03);
            }
            .metric-icon-box {
                width: 45px;
                height: 45px;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1.4rem;
                margin: 0 auto 10px auto;
            }

            .table th {
                font-weight: 700;
                color: #64748b;
                font-size: 0.85rem;
                text-transform: uppercase;
                border-bottom: 2px solid var(--border-color);
            }
            .table td {
                color: var(--text-main);
                font-weight: 600;
                font-size: 0.95rem;
                padding: 15px 10px;
            }
        </style>
    </head>
    <body>

        <div class="sidebar d-flex flex-column">
            <div class="sidebar-header">
                <img src="https://ui-avatars.com/api/?name=<%= user.getNombre()%>&background=e3f2fd&color=0b3b60" class="rounded-circle mb-2" width="60">
                <h6 class="fw-bold mb-0 text-dark"><%= user.getNombre()%></h6>
                <p class="text-muted small mb-0">Control Escolar</p>
            </div>
            <nav class="nav flex-column flex-grow-1">
                <a class="nav-link" href="panel_secretaria.jsp"><i class="bi bi-people-fill"></i> Directorio de Alumnos</a>
                <a class="nav-link active" href="secretaria_materias.jsp"><i class="bi bi-journal-bookmark-fill"></i> Asignar Materias</a>
                <div class="mt-auto mb-4">
                    <a class="nav-link text-danger" href="#" data-bs-toggle="modal" data-bs-target="#modalCerrarSesion"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</a>
                </div>
            </nav>
        </div>

        <div class="main-content">
            <%
                // 1. Traemos las listas (Solo una vez)
                MateriaDAO matDAO = new MateriaDAO();
                List<Materia> listaMaterias = matDAO.listarMaterias();

                MaestroDAO maestroDAO = new MaestroDAO();
                List<Maestro> listaMaestros = maestroDAO.listarMaestros();
                
                GrupoDAO grupoDAO = new GrupoDAO(); 
                List<Grupo> listaGrupos = grupoDAO.listarGrupos();
            %>


            <div class="d-flex justify-content-between align-items-center mb-5">
                <div>
                    <h2 class="fw-bold mb-1" style="color: var(--blue-falyd);">Gestión de Materias</h2>
                    <p class="text-muted small mb-0">Administración del plan de estudios y asignación docente</p>
                </div>
                <div class="d-flex align-items-center">
                    <button class="btn btn-primary fw-bold px-4 py-2 me-4 shadow-sm" data-bs-toggle="modal" data-bs-target="#modalNuevaMateria" style="background-color: var(--blue-falyd); border: none; border-radius: 12px;">
                        <i class="bi bi-journal-plus me-2"></i>Asignar Nueva Materia
                    </button>
                    <div class="d-flex align-items-center bg-white p-2 rounded-pill shadow-sm border">
                        <img src="https://ui-avatars.com/api/?name=<%= user.getNombre()%>&background=e3f2fd&color=0b3b60" class="rounded-circle me-2" width="40">
                        <div class="me-2 lh-sm">
                            <p class="mb-0 fw-bold small"><%= user.getNombre()%></p>
                            <p class="mb-0 text-muted" style="font-size: 0.75rem;">Secretaría</p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row g-4 mb-5">
                <div class="col-md-4">
                    <div class="metric-card border">
                        <div class="metric-icon-box" style="background-color: #fff8e1; color: #f59e0b;"><i class="bi bi-journal-bookmark-fill"></i></div>
                        <p class="text-muted small mb-1 fw-bold">Total de Materias</p>
                        <h3 class="fw-bold text-warning mb-0"><%= listaMaterias.size()%></h3>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="metric-card border">
                        <div class="metric-icon-box" style="background-color: #e8f5e9; color: #43a047;"><i class="bi bi-person-video3"></i></div>
                        <p class="text-muted small mb-1 fw-bold">Maestros Disponibles</p>
                        <h3 class="fw-bold text-success mb-0"><%= listaMaestros.size()%></h3>
                    </div>
                </div>
                    
                <div class="col-md-4">
                    <div class="metric-card border">
                        <div class="metric-icon-box" style="background-color: #e3f2fd; color: #1e88e5;"><i class="bi bi-check-circle-fill"></i></div>
                        <p class="text-muted small mb-1 fw-bold">Estado del Ciclo</p>
                        <h3 class="fw-bold text-primary mb-0">Activo</h3>
                    </div>
                </div>
            </div>

            <div class="card-custom">
                <h5 class="fw-bold mb-4"><i class="bi bi-card-list me-2 text-primary"></i>Materias Oficiales y Maestros Asignados</h5>

                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead>
                            <tr>
                                <th style="width: 120px;">ID Materia</th>
                                <th>Nombre de la Materia</th>
                                <th>Maestro Titular</th>
                                <th>Estado</th>
                                <th class="text-center" style="width: 150px;">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (listaMaterias.isEmpty()) { %>
                            <tr>
                                <td colspan="5" class="text-center py-4 text-muted fw-bold">No hay asignaturas registradas.</td>
                            </tr>
                            <% } else {
                                for (Materia mat : listaMaterias) {
                            %>
                            <tr>
                                <td><strong>#<%= String.format("%04d", mat.getId_materia())%></strong></td>
                                <td>
                                    <span class="badge bg-light text-dark border px-3 py-2 fw-bold fs-6" style="border-radius: 8px;">
                                        <i class="bi bi-book-half me-2 text-primary"></i><%= mat.getNombre_materia()%>
                                    </span>
                                </td>
                                <td class="text-muted"><i class="bi bi-person-video3 me-2"></i>Prof(a). <%= mat.getNombre_maestro()%></td>
                                <td><span class="badge bg-success-subtle text-success border border-success-subtle px-3 py-1.5">Activa</span></td>
                                <td class="text-center">
                                    <button class="btn btn-sm btn-light border text-primary me-1" data-bs-toggle="modal" data-bs-target="#modalEditarMat<%= mat.getId_materia()%>" title="Editar">
                                        <i class="bi bi-pencil-fill"></i>
                                    </button>
                                    <button class="btn btn-sm btn-light border text-danger" data-bs-toggle="modal" data-bs-target="#modalEliminarMat<%= mat.getId_materia()%>" title="Eliminar">
                                        <i class="bi bi-trash-fill"></i>
                                    </button>

                                    <div class="modal fade" id="modalEliminarMat<%= mat.getId_materia()%>" tabindex="-1" aria-hidden="true">
                                        <div class="modal-dialog modal-dialog-centered" style="max-width: 380px;">
                                            <div class="modal-content border-0 shadow" style="border-radius: 20px;">
                                                <form action="MateriaServlet" method="POST">
                                                    <div class="modal-body p-4 text-center">
                                                        <input type="hidden" name="accion" value="eliminar">
                                                        <input type="hidden" name="id_materia" value="<%= mat.getId_materia()%>">

                                                        <div class="mx-auto mb-3 d-flex align-items-center justify-content-center" style="width: 75px; height: 75px; background-color: #fee2e2; border-radius: 50%; color: #ef4444; font-size: 2.2rem;">
                                                            <i class="bi bi-journal-x"></i>
                                                        </div>

                                                        <h4 class="fw-bold mb-2 text-dark">¿Borrar materia?</h4>
                                                        <p class="text-muted small mb-4 px-2">¿Estás seguro de que deseas eliminar <br><strong><%= mat.getNombre_materia()%></strong>? El maestro ya no la tendrá asignada.</p>

                                                        <div class="d-flex justify-content-center gap-3">
                                                            <button type="button" class="btn fw-bold px-4 py-2 flex-grow-1" data-bs-dismiss="modal" style="border: 1px solid var(--border-color); color: var(--blue-falyd); border-radius: 10px; background: white;">Cancelar</button>
                                                            <button type="submit" class="btn btn-danger fw-bold px-4 py-2 flex-grow-1" style="border-radius: 10px; background-color: #e53e3e; border: none;">Sí, borrar</button>
                                                        </div>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="modal fade" id="modalEditarMat<%= mat.getId_materia()%>" tabindex="-1" aria-hidden="true">
                                        <div class="modal-dialog modal-dialog-centered">
                                            <div class="modal-content border-0 shadow" style="border-radius: 20px; text-align: left;">
                                                <div class="modal-header border-0 pb-0" style="padding: 25px 25px 0 25px;">
                                                    <h5 class="modal-title fw-bold text-dark"><i class="bi bi-pencil-square me-2 text-primary"></i>Editar Asignatura</h5>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                </div>
                                                <form action="MateriaServlet" method="POST">
                                                    <div class="modal-body p-4">
                                                        <input type="hidden" name="accion" value="editar">
                                                        <input type="hidden" name="id_materia" value="<%= mat.getId_materia()%>">

                                                        <div class="mb-3">
                                                            <label class="form-label fw-bold small text-muted">Nombre de la Materia</label>
                                                            <input type="text" class="form-control bg-light border-0 fw-bold p-2.5" name="nombre_materia" value="<%= mat.getNombre_materia()%>" required style="border-radius: 10px; color: var(--text-main);">
                                                        </div>

                                                        <div class="mb-3">
                                                            <label class="form-label fw-bold small text-muted">Reasignar Maestro</label>
                                                            <select class="form-select bg-light border-0 p-2.5 fw-bold" name="id_maestro" style="border-radius: 10px; color: var(--blue-falyd);" required>
                                                                <% for (Maestro prof : listaMaestros) {%>
                                                                <option value="<%= prof.getId_maestro()%>" <%= mat.getId_maestro() == prof.getId_maestro() ? "selected" : ""%>>
                                                                    Prof(a). <%= prof.getNombre()%>
                                                                </option>
                                                                <% } %>
                                                            </select>
                                                        </div>
                                                    </div>
                                                            <div class="mb-3">
                            <label class="form-label fw-bold small text-muted">Asignar a Grupo</label>
                            <select class="form-select bg-light border-0 p-2.5" name="id_grupo" required>
                                <% for (Grupo g : listaGrupos) { %>
                                    <option value="<%= g.getId_grupo() %>"><%= g.getNombre_grupo() %></option>
                                <% } %>
                            </select>
                        </div>
                                                    <div class="modal-footer border-0 p-4 pt-0 d-flex gap-2">
                                                        <button type="button" class="btn btn-light border fw-bold px-4 flex-grow-1" data-bs-dismiss="modal" style="border-radius: 10px;">Cancelar</button>
                                                        <button type="submit" class="btn text-white fw-bold px-4 flex-grow-1" style="background-color: var(--blue-falyd); border-radius: 10px;">Actualizar Cambios</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>

                                </td>
                            </tr>
                            <%
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div class="modal fade" id="modalNuevaMateria" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content border-0 shadow" style="border-radius: 20px;">
                    <div class="modal-header border-0 pb-0" style="padding: 25px 25px 0 25px;">
                        <h5 class="modal-title fw-bold text-dark"><i class="bi bi-journal-plus me-2 text-primary"></i>Asignar Nueva Materia</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="MateriaServlet" method="POST">
                        <div class="modal-body p-4">
                            <input type="hidden" name="accion" value="agregar">

                            <div class="mb-3">
                                <label class="form-label fw-bold small text-muted">Nombre de la Materia</label>
                                <input type="text" class="form-control bg-light border-0 p-2.5" name="nombre_materia" placeholder="Ej. Español 2º B" required style="border-radius: 10px;">
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold small text-muted">Asignar a Maestro Titular</label>
                                <select class="form-select bg-light border-0 p-2.5 fw-bold" name="id_maestro" style="border-radius: 10px; color: var(--blue-falyd);" required>
                                    <option value="" selected disabled>Selecciona un maestro...</option>
                                    <% for (Maestro prof : listaMaestros) {%>
                                    <option value="<%= prof.getId_maestro()%>">Prof(a). <%= prof.getNombre()%></option>
                                    <% }%>
                                </select>
                            </div>
                        </div>
                                <div class="mb-3">
                            <label class="form-label fw-bold small text-muted">Asignar a Grupo</label>
                            <select class="form-select bg-light border-0 p-2.5" name="id_grupo" required>
                                <% for (Grupo g : listaGrupos) { %>
                                    <option value="<%= g.getId_grupo() %>"><%= g.getNombre_grupo() %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="modal-footer border-0 p-4 pt-0 d-flex gap-2">
                            <button type="button" class="btn btn-light border fw-bold px-4 flex-grow-1" data-bs-dismiss="modal" style="border-radius: 10px;">Cancelar</button>
                            <button type="submit" class="btn text-white fw-bold px-4 flex-grow-1" style="background-color: var(--blue-falyd); border-radius: 10px;">Guardar Materia</button>
                        </div>
                    </form>
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
                        <p class="text-muted small mb-4 px-2">Estás a punto de salir del sistema de Control Escolar. Tendrás que ingresar tus credenciales nuevamente.</p>
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