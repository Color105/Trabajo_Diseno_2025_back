# db/seeds.rb

# ------------------------------------
# 1. Limpieza de Datos
# ------------------------------------
puts "Limpiando base de datos..."
# Limpia las tablas en orden de dependencia inversa
Tramite.destroy_all
# AgendaConsultor.destroy_all # Descomentar si tienes esta tabla
# HistoricoEstado.destroy_all # Descomentar si tienes esta tabla

Consultor.destroy_all
TipoTramite.destroy_all
puts "Base de datos limpia."

# ------------------------------------
# 2. Consultores (Carga Máxima Eliminada)
# ------------------------------------
puts "Creando Consultores..."
CONSULTORES_DATA = [
  { nombre: "Juan Perez",      email: "juan.perez@example.com" },
  { nombre: "María Gómez",     email: "maria.gomez@example.com" },
  { nombre: "Lucía Fernández", email: "lucia.fernandez@example.com" },
  { nombre: "Carlos López",    email: "carlos.lopez@example.com" },
  { nombre: "Santiago Ruiz",   email: "santiago.ruiz@example.com" }
]
# Creamos los consultores
CONSULTORES_DATA.map { |c| Consultor.create!(c) } # No guardamos en variable local
puts "✅ #{Consultor.count} Consultores creados."

# ------------------------------------
# 3. Tipos de Trámite
# ------------------------------------
puts "Creando Tipos de Trámite..."
TIPOS_DATA = [
  { nombre: "Visa de Trabajo",     plazo_documentacion: 30 },
  { nombre: "Residencia Temporal", plazo_documentacion: 20 },
  { nombre: "Revalidación Título", plazo_documentacion: 45 },
  { nombre: "Permiso de Conducir", plazo_documentacion: 15 }
]
# Creamos los tipos de trámite
TIPOS_DATA.map { |t| TipoTramite.create!(t) } # No guardamos en variable local
puts "✅ #{TipoTramite.count} Tipos de Trámite creados."

# ------------------------------------
# 4. Trámites de Ejemplo (CORRECCIÓN DE ASIGNACIÓN)
# ------------------------------------
puts "Creando Trámites de Ejemplo (LISTO)..."

# ⚠️ CORRECCIÓN CLAVE: Recargamos los objetos desde la BD para asegurar que existan.
consultores = Consultor.all.to_a
tipos = TipoTramite.all.to_a

# Asignaciones (Ahora seguras)
juan, maria, lucia, carlos, santiago = consultores
visa, residencia, revalidacion, permiso = tipos

# Helper para generar códigos
gen_codigo = ->(seq) { "TR-%04d" % seq }

TRAMITES_DATA = [
  { 
    codigo: gen_codigo[1], estado: "ingresado",
    fecha_inicio: 2.days.ago, monto: 1000, 
    consultor: juan, tipo_tramite: visa 
  },
  { 
    codigo: gen_codigo[2], estado: "asignado",
    fecha_inicio: 1.day.ago, monto: 1500, 
    consultor: maria, tipo_tramite: residencia 
  },
  { 
    codigo: gen_codigo[3], estado: "en_proceso",
    fecha_inicio: 3.days.ago, monto: 2500, 
    consultor: lucia, tipo_tramite: visa 
  },
  { 
    codigo: gen_codigo[4], estado: "suspendido",
    fecha_inicio: 5.days.ago, monto: 800, 
    consultor: juan, tipo_tramite: revalidacion 
  },
  { 
    codigo: gen_codigo[5], estado: "terminado",
    fecha_inicio: 7.days.ago, monto: 1200, 
    consultor: maria, tipo_tramite: permiso 
  },
  { 
    codigo: gen_codigo[6], estado: "cancelado",
    fecha_inicio: 9.days.ago, monto: 600, 
    consultor: carlos, tipo_tramite: residencia 
  }
]

# Usamos create! directamente para crear el registro
TRAMITES_DATA.each_with_index do |attrs, index|
  # Este bloque convierte los objetos 'consultor' y 'tipo_tramite' en los IDs
  data_for_creation = attrs.except(:consultor, :tipo_tramite).merge(
    consultor_id: attrs[:consultor].id,
    tipo_tramite_id: attrs[:tipo_tramite].id
  )
  
  begin
    Tramite.create!(data_for_creation)
  rescue ActiveRecord::RecordInvalid => e
    puts "❌ ERROR: Falló la creación del Trámite ##{index + 1} (#{attrs[:codigo]}):"
    puts "  Detalles del Error (Validación): #{e.message}"
    exit 
  rescue => e
    puts "❌ ERROR: Falló la creación del Trámite ##{index + 1} (#{attrs[:codigo]}):"
    puts "  Detalles del Error (Final): #{e.message}"
    exit
  end
end

puts "✅ #{Tramite.count} Trámites de Ejemplo creados."
puts "------------------------------------"
puts "Resumen: Base de datos cargada. Reinicia Rails y prueba la API."
puts "------------------------------------"