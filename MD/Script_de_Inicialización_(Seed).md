require('dotenv').config(); // Cargar variables de entorno
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

// Importar Modelos (Asegúrate de que las rutas sean correctas según tu estructura)
const User = require('../models/User');
const Template = require('../models/Template');
const Settings = require('../models/Settings');
const Project = require('../models/Project'); // Opcional, por si quieres limpiar proyectos

// Configuración de Datos Iniciales
const ADMIN_DATA = {
    email: process.env.ADMIN_EMAIL || 'admin@kiosco.com',
    password: process.env.ADMIN_PASSWORD || 'admin123',
    role: 'superadmin'
};

const INITIAL_QUESTIONS = [
    // Sección A: Propuesta de Valor
    { id: 'q1', text: '¿El proyecto resuelve una problemática clara?', type: 'scale_1_5' },
    { id: 'q2', text: '¿La solución es innovadora o creativa?', type: 'scale_1_5' },
    { id: 'q3', text: '¿El proyecto tiene impacto social o comercial?', type: 'scale_1_5' },
    // Sección B: Ejecución Técnica
    { id: 'q4', text: '¿La interfaz es intuitiva y fácil de usar?', type: 'scale_1_5' },
    { id: 'q5', text: '¿El diseño visual es atractivo?', type: 'scale_1_5' },
    { id: 'q6', text: '¿El proyecto funciona sin errores (bugs) visibles?', type: 'scale_1_5' },
    { id: 'q7', text: '¿La complejidad técnica es adecuada para el nivel?', type: 'scale_1_5' },
    // Sección C: Comunicación
    { id: 'q8', text: '¿La presentación del equipo fue clara?', type: 'scale_1_5' },
    { id: 'q9', text: '¿La documentación mostrada es completa?', type: 'scale_1_5' },
    { id: 'q10', text: '¿Recomendarías este proyecto?', type: 'scale_1_5' }
];

const INITIAL_SECTIONS = [
    { title: 'Propuesta de Valor e Innovación', order: 1, questions: INITIAL_QUESTIONS.slice(0, 3) },
    { title: 'Ejecución Técnica y Diseño', order: 2, questions: INITIAL_QUESTIONS.slice(3, 7) },
    { title: 'Comunicación y Documentación', order: 3, questions: INITIAL_QUESTIONS.slice(7, 10) }
];

const seedDB = async () => {
    try {
        // 1. Conexión a MongoDB
        await mongoose.connect(process.env.MONGO_URI);
        console.log('🔌 Conectado a MongoDB...');

        // 2. Limpieza (Opcional: Borra todo para empezar limpio)
        // ¡CUIDADO! Esto borra los datos existentes. Úsalo solo en desarrollo.
        console.log('🧹 Limpiando colecciones...');
        await User.deleteMany({});
        await Template.deleteMany({});
        await Settings.deleteMany({});
        // await Project.deleteMany({}); // Descomentar si quieres borrar proyectos también

        // 3. Crear Usuario Admin
        console.log('👤 Creando Superadmin...');
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(ADMIN_DATA.password, salt);
        
        await User.create({
            email: ADMIN_DATA.email,
            password: hashedPassword,
            role: 'superadmin'
        });

        // 4. Crear Plantilla v1.0
        console.log('📝 Creando Plantilla de Evaluación v1.0...');
        await Template.create({
            version: 'v1.0',
            is_active: true,
            sections: INITIAL_SECTIONS
        });

        // 5. Crear Configuración Global
        console.log('⚙️ Estableciendo Configuración Inicial...');
        await Settings.create({
            event_name: 'Feria de Proyectos 2026',
            voting_enabled: false, // Por defecto cerrado
            ranking_public: false  // Por defecto oculto
        });

        console.log('✅ ¡Seeding completado con éxito!');
        process.exit(0);

    } catch (error) {
        console.error('❌ Error en el seeding:', error);
        process.exit(1);
    }
};

// Ejecutar
seedDB();