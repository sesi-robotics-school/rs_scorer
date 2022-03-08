extends Resource
class_name Score


func as_json() -> String:
	return to_json(missions)


func from_json(text: String) -> int:
	var parser := JSON.parse(text)
	if parser.error != OK:
		return parser.error
	else:
		missions = parser.result
		return OK


var missions: Array = [
	# M00: Bỗônus de Insperação dos Equipamentos (20)
	# - Todos os equipamentos cabem na área de insperação menor
	false,
	# M01: Modelo do Projeto de Inovação (20)
	# - É formado por ao menos duas peças LEGO brancas
	# - Tem o comprimento de, pelo meno, quatro "pinos" de um bloco LEGO em uma das direções
	# - Qualquer uma de suas partes está tocando no círculo CARGO CONNECT
	false,
	# M02: Capacidade Não Utilizada (20 | 30)
	# - 0 < Peças < 6 (20) | Peças = 6 (30)
	# - Está fechado
	[0, false],
	# M03: Descarga de Avião Cargueiro (20 + 10)
	# - Porta tocando estrutura preta (20)
	# - Contâiner completamente separado do avião (10)
	[false, false],
	# M04: Jornada dos Transportes (10 + 10 + 10)
	# - Caminhão ultrapassou linha azul (10)
	# - Avião ultrapassou linha azul (10)
	# - Ambos ultrapassaram (10)
	[false, false],
	# M05: Troca de Motor (20)
	# - 270° graus rotacionados de sua origem
	false,
	# M06: Prevenção de Acidentes (20 | 30)
	# - Robô estacionado aṕpós linha azul
	# - Painel não derrubado (20) | Painel derrubado (30)
	[false, false],
	# M07: Descarga de Navio Cargueiro (20 + 10)
	# - Contâiner sem tocar convés leste (20)
	# - Completamente a laste do convés leste (10)
	[false, false],
	# M08: Lançamento Aéreo (20 + 10 + 10)
	# - Carga de Alimentos separada do helicóptero da equipe (20)
	# - Carga de Alimentos da arena vizinha no círculo CARGO CONNECT (10)
	# - Ambas as equipes separaram suas cargas em suas arenas (10)
	[false, false],
	# M09: Trilhos de Trem (20 + 20)
	# - Trilhos do trem abaixados (20)
	# - Trem ultrapassando a trava (20)
	[false, false],
	# M10: Centro de Distribuição (20)
	# - Laranja sendo o único contâiner restante
	false,
	# M11: Entrega em Domicílio (20 + 10)
	# - Encomenda entregue (20)
	# - Acima do degrau (10)
	[false, false],
	# M12: Entrega de Grandes Volumes (20 + 10 + 5 + 10)
	# - Lâmina entregue sem nenhum equipamento tocando (20)
	# - Lâmina sem tocar ao tapete (10)
	# - Estátua da Galinha dentro de seu círculo (5)
	# - Estátua da Galinha completamente dentro de seu círculo (10)
	[false, false, false, false],
	# M13: Caminhões Conectados (10 + 10 + 10)
	# - Ambos conectados e fora da área do robô (10)
	# - Um travado à ponte (10)
	# - Ambas as afirmações verdadeiras (10)
	[false, false],
	# M14: Ponte (10 + 10)
	# - Lado esquerdo abaixado
	# - Lado direito abaixado
	0,
	# M15: Carregamento de Carga (10x + 20y + 30z)
	# - Contâiners em caminhões Conectados (10x)
	# - Trem (20x)
	# - Convés do Navio (30x)
	[0, 0, 0],
	# M16: CARGO CONNECT (5x + 10y + 20 + 20 + 10z)
	# - Contâiner parcialmente em círculo (5x)
	# - Contâiner completamente em círculo (10x)
	# - Contâiner azul no círculo azul (20)
	# - Contâiner verde no círculo verde (20)
	# - Algum círculo com ao menos um contâiner (10x)
	[0, 0, false, false, 0],
	# M17: Discoes de Precisão (0 ~ 50)
	# - 1: 10
	# - 2: 15
	# - 3: 25
	# - 4: 35
	# - 5: 50
	# - 6: 50
	6
]


func calc() -> int:
	var score: int = 0

	for i in range(missions.size()):
		score += calc_mission(i, missions[i])

	return score


static func calc_mission(id: int, data) -> int:
	match id:
		0:
			return int(data) * 20
		1:
			return int(data) * 20
		2:
			return int(data[1]) * 20 + int(data[0] == 6) * 10
		3:
			return int(data[0]) * 20 + int(data[1]) * 10
		4:
			return int(data[0]) * 10 + int(data[1]) * 10 + int(data[0] and data[1]) * 10
		5:
			return int(data) * 20
		6:
			return (30 if int(data[1]) else 20) * int(data[0])
		7:
			return (int(data[0])  * 2 + int(data[1])) * 10
		8:
			return (int(data[0] and data[1]) + int(data[1])) * 10 + int(data[0]) * 20
		9:
			return (int(data[0]) + int(data[1])) * 20
		10:
			return int(data) * 20
		11:
			return (30 if data[1] else 20) * int(data[0])
		12:
			return (30 if data[1] else 20) * int(data[0]) + int(data[2]) * 5 + int(data[3]) * 5
		13:
			return (int(data[0]) + int(data[1]) + int(data[0] and data[1])) * 10
		14:
			return int(data) * 10
		15:
			return int(data[0]) * 10 + int(data[1]) * 20 + int(data[2]) * 30
		16:
			return (
				int(data[0]) * 5
				+ int(data[1]) * 10
				+ int(data[2]) * 20
				+ int(data[3]) * 20
				+ int(data[4]) * 10
			)
		17:
			return [0, 10, 15, 25, 35, 50, 50][data]
		_:
			return 0
