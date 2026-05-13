// OpenSCAD model
// Малый логотип дайв клуба Neva Divers
// Version 1.2.2
// Author: msp
// Date: 2026-04-22
// =============================================

// === ПАРАМЕТРЫ ===
$fn = 100;

shortTxtFont    = "Noto Serif:style=Bold";
txtLogoSize     = 10;
thickness_line  = 1; 

// Волна
step            = 0.5;      
length          = 70;    
amplitude       = 2;   
  

module ellipse(w, k=0.6) {
    scale([w/2, w*k/2]) circle(r=1, $fn = 100);
}

module oval_ring(w, t, k=0.6) {
    difference() {
        ellipse(w, k);
        ellipse(w - 2*t, k);
    }
}

// --- ВОЛНА ---
module wave(thickness_line) {
    // Смещение для центрирования волны внутри овала
    translate([-25, -12, 0])
    for (i = [-20 : step : length]) {
        translate([i, amplitude * sin(i * 8), 0])
            circle(r = thickness_line, $fn = 20);
    }
}

// Маска, которая закрывает всё пространство НИЖЕ линии волны
module wave_bottom_mask() {
    translate([-25, -12, 0])
    for (i = [-20 : step : length]) {
        translate([i, amplitude * sin(i * 8) - 25, 0])
            square([step * 1.5, 50], center=true);
    }
}

// --- КОРОТКАЯ ФОРМА (ND) ---
module txt_short_form () {
    translate([-4.5, 0, 0])
        text("N", font = shortTxtFont, size = 14, halign = "center", valign = "center");
    translate([4.5, 0, 0])
        text("D", font = shortTxtFont, size = 14, halign = "center", valign = "center");
}

// --- СБОРКА  ---
module build_small_logo (thickness_line) {
    union() {
        // 1. Внутренняя рамка
        oval_ring(66, thickness_line*2, 0.66);

        // 2. Меридианы, обрезанные волной
        difference() {
            intersection() {
                oval_ring(49, thickness_line*2, 0.87); // Вертикальный эллипс (меридиан)
                ellipse(63, 0.68);      // Ограничение внутренним пространством
            }
            wave_bottom_mask();        // Удаляем всё, что ниже волны
        }

        // 3. Линия волны
        intersection() {
            wave(thickness_line);
            ellipse(66, 0.66); // Чтобы концы волны не вылезали за рамку
        }

        // 4. Линии
        intersection() { // правая
            translate([25, 0, 0]) square([20, thickness_line*2], center=true);
            ellipse(66, 0.6);
        }
        intersection() { // левая
            translate([-25, 0, 0]) square([20, thickness_line*2], center=true);
            ellipse(66, 0.6);
        }
        intersection() { // вертикальная
            translate([0, 16, 0]) square([thickness_line*2, 10], center=true);
            ellipse(66, 0.6);
        }

        // 5. Текст
        txt_short_form();
    }
}

// Рендер
build_small_logo(thickness_line);
