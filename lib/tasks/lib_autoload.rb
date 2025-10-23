# Agrega /lib al autoloader de Zeitwerk
Rails.autoloaders.main.push_dir(Rails.root.join("lib"))
