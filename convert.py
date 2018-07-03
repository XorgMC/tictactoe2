import pickle as pickle
import json

Q = pickle.load(open("Q_epsilon_09_Nepisodes_200000.p", "rb"))
Q2 = {}

def get_field(tpl):
	if tpl == (0, 0):
		return "0"
	elif tpl == (0, 1):
		return "1"
	elif tpl == (0, 2):
		return "2"
	elif tpl == (1, 0):
		return "3"
	elif tpl == (1, 1):
		return "4"
	elif tpl == (1, 2):
		return "5"
	elif tpl == (2, 0):
		return "6"
	elif tpl == (2, 1):
		return "7"
	elif tpl == (2, 2):
		return "8"
	else:
		return "-1"

for key, value in Q.items():
	lazBoard = key.replace('1', 'X').replace('0', 'O').replace('9', '_')
	Q2[lazBoard] = {}
	for k2, v2 in value.items():
		fld = get_field(k2)
		Q2[lazBoard][fld] = Q[key][k2]

with open('learn.json', 'w',  encoding='utf8') as f:
	json.dump(Q2, f, indent=4, sort_keys=True, ensure_ascii=False)


print(Q2)


