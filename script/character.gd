extends CharacterBody2D

const CELL_SIZE: int = 64
const GRID_WIDTH: int = 12    # ширина сетки в клетках
const GRID_HEIGHT: int = 8    # высота
const MOVE_SPEED: float = 300.0  # пикселей/сек — подгони под вкус
const TAG: String = "[character 2d, bobot]"

@onready var level: Node2D = get_parent()  # Level — родитель

var grid_pos: Vector2i = Vector2i(2, 2)     # стартовая позиция (центр)
var target_grid_pos: Vector2i
var is_moving: bool = false


func tagged_print(string) -> void:
	print(TAG + " " + string)

func _ready() -> void:
	snap_to_grid()
	tagged_print("готов на клетке: " + str(grid_pos))  # для дебага

func snap_to_grid() -> void:
	global_position = grid_to_world(grid_pos)

func grid_to_world(grid: Vector2i) -> Vector2:
	return Vector2(grid) * CELL_SIZE + Vector2(CELL_SIZE * 0.5, CELL_SIZE * 0.5)

func _physics_process(delta: float) -> void:
	if is_moving:
		# Плавное движение к цели
		var target_world = grid_to_world(target_grid_pos)
		var direction = (target_world - global_position).normalized()
		velocity = direction * MOVE_SPEED
		move_and_slide()
		
		# Приехали?
		if global_position.distance_to(target_world) < 3.0:
			grid_pos = target_grid_pos
			snap_to_grid()  # точная позиция
			is_moving = false
			tagged_print("Прибыл на клетку: " + str(grid_pos))  # деbag
	else:
		handle_input()

func handle_input() -> void:
	# Проверяем нажатия стрелок (just_pressed — один шаг за клик)
	if Input.is_action_just_pressed("ui_left"):
		try_move(Vector2i(-1, 0))
	elif Input.is_action_just_pressed("ui_right"):
		try_move(Vector2i(1, 0))
	elif Input.is_action_just_pressed("ui_up"):
		try_move(Vector2i(0, -1))
	elif Input.is_action_just_pressed("ui_down"):
		try_move(Vector2i(0, 1))

func try_move(direction: Vector2i) -> void:
	var new_pos: Vector2i = grid_pos + direction
	
	# Проверка границ (потом заменим на реальную сетку с TileMap)
	if new_pos.x >= 0 and new_pos.x < GRID_WIDTH and new_pos.y >= 0 and new_pos.y < GRID_HEIGHT:
		target_grid_pos = new_pos
		is_moving = true
		tagged_print("Иду на: " + str(new_pos))  # деbag
	else:
		tagged_print("Стена/граница на: " +  str(new_pos))  # деbag
