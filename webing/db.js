const mysql = require('mysql2');

// Crear pool de conexiones para mejor rendimiento
const pool = mysql.createPool({
  host: 'localhost',
  user: 'root',
  password: 'mnu14567',
  database: 'prueba_pepsi',
  port: 3306,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Verificar conexión
pool.getConnection((err, connection) => {
  if (err) {
    console.error('❌ Error al conectar con la base de datos:', err);
    return;
  }
  console.log('✅ Conectado a MySQL correctamente');
  console.log('📊 Base de datos: prueba_pepsi');
  connection.release();
});

module.exports = pool;