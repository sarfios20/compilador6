struct ast {
    int nodetype;
    struct ast *l;
    struct ast *r;
};

struct asignar {
    int nodetype;
    struct ast *as;
};

struct realval {
    int nodetype;
    float number;
    char* indentificador;
};

struct intval {
    int nodetype;
    int   number;
    char* indentificador;
};

struct strval {
    int nodetype;
    char* str;
};

struct boolval {
    int nodetype;
    int boolean;
	char* indentificador;
};
