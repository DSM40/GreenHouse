clc; clear; close all;

% Ruta de la carpeta con las imágenes
ruta_carpeta = 'C:\Users\moren\Documents\Doctorado\imagenes acelgas\CAP2203LR'; % Asegúrate de cambiar esto
archivos = dir(fullfile(ruta_carpeta, '*.jpg')); % Filtrar imágenes .jpg

% Relación píxeles/cm² (ajusta con tu calibración)
relacion_pixeles_cm2 = 469.51;

% Inicializar resultados
resultados = {'Nombre de Imagen', 'Área en Píxeles', 'Área en cm²'};

% Procesar cada imagen en la carpeta
for i = 1:length(archivos)
    nombre_imagen = archivos(i).name;
    ruta_imagen = fullfile(ruta_carpeta, nombre_imagen);
    imagen = imread(ruta_imagen);

    % Convertir a espacio de color HSV
    imagen_hsv = rgb2hsv(imagen);

    % Definir el rango de color verde
    verde_min = [0.14, 0.2, 0.2]; 
    verde_max = [0.25, 1, 1];

    % Crear máscara para el área foliar
    mascara = (imagen_hsv(:,:,1) >= verde_min(1) & imagen_hsv(:,:,1) <= verde_max(1)) & ...
              (imagen_hsv(:,:,2) >= verde_min(2) & imagen_hsv(:,:,2) <= verde_max(2)) & ...
              (imagen_hsv(:,:,3) >= verde_min(3) & imagen_hsv(:,:,3) <= verde_max(3));

    % Operaciones morfológicas
    masc = strel('disk', 5);
    mascara = imopen(mascara, masc); % Combinación de erosión y dilatación
    erosionada=imerode(mascara,masc);
    dilatada=imdilate(erosionada,masc);
    %figure, imshow(dilatada);


    % Calcular el área en píxeles
    area_pixeles = sum(dilatada(:));

    % Convertir a cm²
    area_cm2 = area_pixeles / relacion_pixeles_cm2;

    % Mostrar resultados en la consola
    fprintf('Imagen: %s | Área en píxeles: %d | Área en cm²: %.2f\n', nombre_imagen, area_pixeles, area_cm2);

    % Guardar los resultados en la tabla
    resultados = [resultados; {nombre_imagen, area_pixeles, area_cm2}];
end

% Guardar en un archivo Excel
nombre_excel = fullfile(ruta_carpeta, 'resultados_area_foliar.xlsx');
%writecell(resultados, nombre_excel);
xlswrite(nombre_excel, resultados);

fprintf('Resultados guardados en: %s\n', nombre_excel);
