const express = require('express');
const path = require('path');
const app = express();
const port = 3000;
//Importa la conexión
const db = require('./db');

//Permite recibir JSON en peticiones POST
app.use(express.json());

app.use(express.static(path.join(__dirname, 'public')));//carpeta hija

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'inicio-sesion.html'));
});

// 🔐 ENDPOINT DE LOGIN
app.post('/api/login', (req, res) => {
  const { usuario, contrasena } = req.body;

  console.log('🔐 Intento de login para:', usuario);

  if (!usuario || !contrasena) {
    return res.status(400).json({
      success: false,
      message: 'Usuario y contraseña son requeridos'
    });
  }

  const query = 'SELECT usuario, contrasena FROM empleados WHERE usuario = ? AND contrasena = ?';

  db.query(query, [usuario, contrasena], (err, results) => {
    if (err) {
      console.error('❌ Error en consulta MySQL:', err);
      return res.status(500).json({
        success: false,
        message: 'Error del servidor en la base de datos'
      });
    }

    if (results.length > 0) {
      const empleado = results[0];
      console.log('✅ Login exitoso para:', empleado.nombre);

      res.json({
        success: true,
        message: 'Login exitoso',
        empleado: {
          rut: empleado.rut,
          nombre: empleado.nombre,
          cargo: empleado.cargo,
          region: empleado.region,
          horario: empleado.horario,
          disponibilidad: empleado.disponibilidad,
          usuario: empleado.usuario
        }
      });
    } else {
      console.log('❌ Credenciales incorrectas para:', usuario);
      res.status(401).json({
        success: false,
        message: 'Usuario o contraseña incorrectos'
      });
    }
  });
});

// 🩺 ENDPOINT PARA VERIFICAR ESTADO
app.get('/api/status', (req, res) => {
  db.query('SELECT 1 as test', (err, results) => {
    if (err) {
      return res.json({
        status: 'Servidor funcionando pero BD con error',
        error: err.message,
        timestamp: new Date().toISOString()
      });
    }

    res.json({
      status: 'Servidor y BD funcionando correctamente',
      timestamp: new Date().toISOString(),
      base_datos: 'prueba_pepsi'
    });
  });
});

// 👥 ENDPOINT PARA OBTENER EMPLEADOS
app.get('/api/empleados', (req, res) => {
  db.query('SELECT rut, nombre, cargo, region, usuario FROM empleados', (err, results) => {
    if (err) {
      console.error('Error al obtener empleados:', err);
      return res.status(500).json({ error: 'Error en la consulta' });
    }
    res.json(results);
  });
});

app.get('/api/status', (req, res) => {
  res.json({ base_datos: 'Conectado' });
});

// Ruta de login
app.post('/api/login', (req, res) => {
  const { usuario, contrasena } = req.body;

  if (!usuario || !contrasena) {
    return res.status(400).json({ success: false, message: 'Faltan datos de usuario o contraseña' });
  }

  // Consulta MySQL
  const sql = 'SELECT usuario, contrasena FROM empleados WHERE usuario = ? AND contrasena = ?';
  db.query(sql, [usuario, contrasena], (err, results) => {
    if (err) {
      console.error('❌ Error en consulta MySQL:', err);
      return res.status(500).json({ success: false, message: 'Error en el servidor' });
    }

    if (results.length === 0) {
      // No se encontró el usuario
      return res.status(401).json({ success: false, message: 'Usuario o contraseña incorrectos' });
    }

    // Si llega aquí, hay coincidencia
    const empleado = results[0];
    res.json({
      success: true,
      message: 'Inicio de sesión exitoso',
      empleado: {
        id: empleado.id,
        nombre: empleado.nombre,
        cargo: empleado.cargo,
        usuario: empleado.usuario
      }
    });
  });
});



//Inicia el servidor
app.listen(port, () => {
  console.log(`Servidor iniciado en http://localhost:${port}`);
  // Escuchar en todas las interfaces de red
  console.log(`📋 Endpoints disponibles:`);
  console.log(`   POST http://localhost:${port}/api/login`);
  console.log(`   GET  http://localhost:${port}/api/status`);
  console.log(`   GET  http://localhost:${port}/api/empleados`);
});

const cors = require('cors');
app.use(cors());