// OpenSCAD model
// Логотип дайв клуба Neva Divers
// Version 2.0
// Author: msp
// Date: 2026-04-22
// ---------------------------------------------

// === ПАРАМЕТРЫ ===
$fn = 100;

shortTxtFont    = "Noto Serif:style=Bold";
longTxtFont     = "Noto Sans:style=ExtraCondensed Bold";

txtUpperSpacing = 6;            // растояние между буквами
txtUpperSize    = 9;
txtUpperOffset  = -25;
txtUpperRadius  = 54;

txtLowerSpacing = 4.2;            
txtLowerSize    = 6;
txtLowerOffset  = 23;
txtLowerRadius  = 53;

// Волна
step            = 0.5;      
length          = 70;    
amplitude       = 2;   
thickness       = 1;   

module ellipse(w, k=0.6) {
    scale([w/2, w*k/2]) circle(r=1);
}

module oval_ring(w, t, k=0.6) {
    difference() {
        ellipse(w, k);
        ellipse(w - 2*t, k);
    }
}

// --- ВОЛНА ---
module wave() {
    // Смещение для центрирования волны внутри овала
    translate([-25, -12, 0])
    for (i = [-20 : step : length]) {
        translate([i, amplitude * sin(i * 8), 0])
            circle(r = thickness, $fn = 20);
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

// --- Текст по дуге ---
module arc_bottom_text(text_str, start_angle, txt_radius, txt_size, txt_spacing, txt_rotate) {
    chars = [for(i=[0:len(text_str)-1]) text_str[i]];
    
    char_angle = txt_spacing / txt_radius * 180 / PI;  // угол на символ 
    
    if (txt_rotate) {
        for(i = [0:len(chars)-1]) {
            char_angle_pos = start_angle + i * char_angle - (len(chars)-1) * char_angle / 2;
        rotate([0, 0, char_angle_pos])
        translate([0, txt_radius, 0])
        rotate([180, 0, 0])  // Дополнительный поворот на 180° по X
        mirror([1,0,0])
        text(chars[i], size=txt_size, font=longTxtFont, 
            halign="center", valign="center", $fn=30);
        }
     } else { 
        for(i = [0:len(chars)-1]) {
            char_angle_pos = start_angle + i * char_angle - (len(chars)-1) * char_angle / 2;
        rotate([0, 0, -char_angle_pos + start_angle])
        translate([0, txt_radius, 0])
        text(chars[i], size=txt_size, font=longTxtFont, 
            halign="center", valign="center", $fn=30);
        }
    }
}


// --- СБОРКА  ---
module build_logo () {
    union() {
        // 1. Внутренняя рамка
        oval_ring(66, 2, 0.66);

        // 2. Меридианы, обрезанные волной
        difference() {
            intersection() {
                oval_ring(49, 2, 0.87); // Вертикальный эллипс (меридиан)
                ellipse(63, 0.68);      // Ограничение внутренним пространством
            }
            wave_bottom_mask();        // Удаляем всё, что ниже волны
        }

        // 3. Линия волны
        intersection() {
            wave();
            ellipse(66, 0.66); // Чтобы концы волны не вылезали за рамку
        }

        // 4. Линии
        intersection() { // правая
            translate([25, 0, 0]) square([20, 2], center=true);
            ellipse(66, 0.6);
        }
        intersection() { // левая
            translate([-25, 0, 0]) square([20, 2], center=true);
            ellipse(66, 0.6);
        }
        intersection() { // вертикальная
            translate([0, 16, 0]) square([2, 10], center=true);
            ellipse(66, 0.6);
        }

        // 5. Текст
        txt_short_form();

        translate([0, txtUpperOffset, 0])
        arc_bottom_text("NEVA DIVERS", 0, txtUpperRadius, txtUpperSize, txtUpperSpacing, false);
        
        translate([0, txtLowerOffset, 0])
        arc_bottom_text("ADVANCED TRAINING FACILITY", 180, txtLowerRadius, txtLowerSize, txtLowerSpacing, true);
        
        // 6. Точки
        translate([-40, 8])circle (2.6);
        translate([40, 8])circle (2.6);
        
        // 7. Внешняя рамка
        oval_ring(108, 2, 0.7);
    }
}

// Рендер
build_logo();
