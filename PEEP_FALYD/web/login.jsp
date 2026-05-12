<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Acceso - Sistema Web Escolar FALYD</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

        <style>
            /* Pequeños ajustes para igualar tu diseño FALYD */
            body {
                background-color: #f8f9fa; /* Color de respaldo */
                /* AQUI AGREGAMOS LA IMAGEN DE FONDO */
                background-image: url('img/fondoLogin.png');
                background-size: cover;
                background-position: center;
                background-repeat: no-repeat;
                background-attachment: fixed;
            }

            .login-card {
                border-radius: 15px;
                box-shadow: 0 4px 15px rgba(0,0,0,0.1);
                border: none;
                background-color: rgba(255, 255, 255, 0.92);
            }

            .btn-falyd {
                background-color: #0b3b60;
                color: white;
                border-radius: 8px;
                font-weight: 500;
            }
            .btn-falyd:hover {
                background-color: #082a45;
                color: white;
            }
            .text-falyd-red {
                color: #d32f2f;
            }
            .form-control, .form-select {
                border-radius: 8px;
            }
            .input-group-text {
                background-color: transparent;
                border-right: none;
            }
            .input-with-icon {
                border-left: none;
            }
            .logo-falyd {
                width: 250px;
                height: auto;
            }

            .titulo-sistema {
                color: #0b3b60;
                font-weight: 700;
                font-size: 1.6rem;
                line-height: 1.1;
            }

            .subtitulo-sistema {
                color: #6c757d;
                font-size: 1rem;
            }
        </style>
    </head>
    <body class="d-flex align-items-center min-vh-100">

        <div class="container">
            <div class="row align-items-center justify-content-center">

                <div class="col-md-5 text-center text-md-start mb-5 mb-md-0" style="transform: translateY(-90px);">                    <div class="d-flex align-items-center justify-content-center justify-content-md-start mb-4">
                        <img src="img/Logo.png" alt="Logo FALYD" class="logo-falyd me-3">

                        <div>
                            <h2 class="titulo-sistema mb-1">
                                Sistema Web<br>
                                Escolar Luis Moya
                            </h2>
                            <p class="subtitulo-sistema mb-0">
                                Acceso al sistema
                            </p>
                        </div>
                    </div>

                    <h1 class="fw-bold" style="color: #0b3b60;">Bienvenido</h1>
                    <p class="text-muted fs-5">Inicia sesión para acceder a todas las herramientas educativas.</p>
                </div>

                <div class="col-md-5">
                    <div class="card login-card p-4">
                        <div class="card-body">
                            <h3 class="text-center fw-bold mb-4" style="color: #0b3b60;">
                                Iniciar sesión
                                <hr class="w-25 mx-auto text-falyd-red border-2 opacity-100">
                            </h3>

                            <form action="LoginServlet" method="POST">

                                <div class="mb-3">
                                    <label class="form-label fw-bold text-muted small">Tipo de usuario</label>
                                    <div class="input-group">
                                        <span class="input-group-text text-falyd-red"><i class="bi bi-person-badge-fill"></i></span>
                                        <select class="form-select input-with-icon" name="tipo_usuario" required>
                                            <option value="" selected disabled>Selecciona tu rol</option>
                                            <option value="ALUMNO">Alumno</option>
                                            <option value="MAESTRO">Maestro</option>
                                            <option value="ADMIN">Administrador</option>
                                            <option value="SECRETARIA">Secretaría</option>
                                        </select>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label fw-bold text-muted small">Usuario</label>
                                    <div class="input-group">
                                        <span class="input-group-text" style="color: #0b3b60;"><i class="bi bi-person-fill"></i></span>
                                        <input type="email" class="form-control input-with-icon" name="correo" placeholder="Ingresa tu correo" required>
                                    </div>
                                </div>

                                <div class="mb-4">
                                    <label class="form-label fw-bold text-muted small">Contraseña</label>
                                    <div class="input-group">
                                        <span class="input-group-text text-falyd-red"><i class="bi bi-lock-fill"></i></span>
                                        <input type="password" class="form-control input-with-icon" name="password" placeholder="Ingresa tu contraseña" required>
                                        <span class="input-group-text"><i class="bi bi-eye"></i></span>
                                    </div>
                                </div>

                                <div class="d-grid gap-2 mb-3">
                                    <button type="submit" class="btn btn-falyd btn-lg py-2">
                                        <i class="bi bi-box-arrow-in-right me-2"></i> Entrar
                                    </button>
                                </div>

                                <div class="text-center mb-3">
                                    <a href="#" class="text-decoration-none text-muted small">¿Olvidaste tu contraseña?</a>
                                </div>

                                <div class="text-center text-muted small mt-4">
                                    <span class="text-falyd-red">|</span> Educamos hoy para un mejor mañana <i class="bi bi-heart text-falyd-red"></i>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>