#scope_export

get_plugin :: () -> *Metaprogram_Plugin
{
	plug := New(Widener);
	plug.message = xx message;
	plug.finish  = xx finish;


	
	return xx plug;
}


#scope_file

Annotation :: "Widen";
Annotation_Reference :: "WidenedFrom";

Widener :: struct
{
	using #as base : Metaprogram_Plugin;

	procs : [..] Widened_Procedure;
}


Widened_Procedure :: struct
{
	original : *Code_Procedure_Header;
	widened : [3] *Code_Procedure_Header;

	done : bool = false;
}
Wide :: enum
{
	x2 :: 0;
	x4 :: 1;
	x8 :: 2;
};

message :: (using plug : *Widener, msg : *Message)
{
	if msg.workspace != plug.workspace  return;
	if msg.kind == .TYPECHECKED
	{
		tc := cast(*Message_Typechecked)msg;
		for tc.procedure_headers
		{
			procedure := it.expression;
			if has_Note(procedure, Annotation)
			{
				array_add(*procs, Widened_Procedure.{original = procedure});
			}
			is_reference, note := has_Note_Starting_With(procedure, Annotation_Reference);
			if is_reference
			{

				_, _, remainder := split_from_left(note, #char "(");

				found_comma, function, wideness_rest := split_from_left(remainder, #char ",");
				assert(found_comma);
				

				wide, succ := parse_int(*wideness_rest);

				index_of_proc := -1;
				for procs
				{
					if function == it.original.name
					{	
						index_of_proc = it_index;
						break;
					}
				}
				if index_of_proc >= 0
				{
					if wide == 2
					{
						procs[index_of_proc].widened[Wide.x2] = procedure;
					}else if wide == 4
					{
						procs[index_of_proc].widened[Wide.x4] = procedure;
					}else if wide == 8
					{
						procs[index_of_proc].widened[Wide.x8] = procedure;
					}
				}
			}
		}
	}

	for * procs
	{
		if it.done  continue;
		if atomic_read(*it.original.body_or_null) == null  continue;
		generate_Widened_Proc :: (proc : *Code_Procedure_Header, workspace : Workspace, wide : int)
		{
			c := context;
			c.allocator = __temporary_allocator;
			push_context,defer_pop c;
			mark := get_temporary_storage_mark();
			defer set_temporary_storage_mark(mark);
			widened := widen_Procedure(proc, wide);
			decl_as_string : string;
			{
				builder : String_Builder;
				decl : Code_Declaration;
				decl.expression = widened;
				decl.flags |= .IS_CONSTANT;
				decl.name = widened.name;
				print_declaration(*builder, *decl);
				decl_as_string = builder_to_string(*builder);
			}
			add_build_string(decl_as_string, workspace, cast(*Message)null);
		}
		generate_Widened_Proc(it.original, plug.workspace ,2);
		generate_Widened_Proc(it.original, plug.workspace ,4);
		generate_Widened_Proc(it.original, plug.workspace, 8);
		it.done = true;
	}
}

finish :: (using plug : *Widener)
{
	log("Wider Report:");
	log("% Procedures", procs.count);
	for procs
	{
		log("%:", it.original.name);
		for w: it.widened
		{
			if w  log("\t-> %", w.name);
		}
		
	}
}



widen_Procedure :: (header : *Code_Procedure_Header, wide : int) -> *Code_Procedure_Header
{
	new_header := New(Code_Procedure_Header);
	new_header.* = header.*;
	new_header.name = sprint("%_x%", header.name, wide);
	new_header.notes = NewArray(1 + header.notes.count - 1, *Code_Note);
	note_base := 0;
	for header.notes
	{
		if it.text == Annotation  continue; // Dont widen the widened
		new_header.notes[note_base] = it;
		note_base += 1;
	}
	note := New(Code_Note);
	note.text = sprint("%(%,%)", Annotation_Reference, header.name, wide);
	new_header.notes[new_header.notes.count - 1] = note;

	new_header.arguments = NewArray(header.arguments.count, *Code_Declaration);
	new_header.returns   = NewArray(header.returns  .count, *Code_Declaration);

	assert(header.parameter_usings.count == 0, "using is not supported");

	for header.arguments
	{
		decl := New(Code_Declaration);
		decl.name = it.name;
		decl.flags = it.flags;
		decl.type_inst = type_Inst_To_Array(it.type_inst, wide);
		new_header.arguments[it_index] = decl;
	}
	for header.returns
	{
		decl := New(Code_Declaration);
		decl.name = it.name;
		decl.flags = it.flags;

		decl.type_inst = type_Inst_To_Array(it.type_inst, wide);
		new_header.returns[it_index] = decl;
	}
	n_returns := header.returns.count;
	
	{
		
		body := header.body_or_null;
		block := body.block;

		new_body := New(Code_Procedure_Body);
		new_body.kind = .PROCEDURE_BODY;
		new_body.header = new_header;

		new_header.body_or_null = new_body;
		new_body.* = body;

		new_block := New(Code_Block);
		new_block.kind = .BLOCK;
		new_body.block = new_block;

		new_block.block_type = .IMPERATIVE;
		new_block.block_flags = block.block_flags;
		new_block.statements = NewArray(n_returns + 1 + block.statements.count, *Code_Node);
		new_block.members    = NewArray(block.members.count + header.arguments.count + header.returns.count, *Code_Scope_Entry);



		for header.returns
		{
			decl := New(Code_Declaration);
			if it.name  decl.name = it.name;
			else        decl.name = sprint("return_value_%", it_index);

			decl.type_inst = new_header.returns[it_index].type_inst;
			new_block.statements[it_index] = decl;
		}
		members_base := 0;
		{
			for header.arguments
			{
				new_block.members[members_base + it_index] = new_header.arguments[it_index];
			}
			members_base += header.arguments.count;
			for header.returns
			{
				new_block.members[members_base + it_index] = xx new_block.statements[it_index];
			}
			members_base += header.returns.count;
		}

		empty := New(Code_Block);
		empty.kind = .BLOCK;
		for block.statements
		{
			fill_ptr := *new_block.statements[n_returns + it_index];
			if it.kind ==
			{
			case .DECLARATION;
				decl := cast(*Code_Declaration)it;
				new_decl := New(Code_Declaration);
				new_decl.type_inst = type_Inst_To_Array(decl.type_inst, wide);
				new_decl.name = decl.name;
				new_decl.flags = decl.flags;
				new_decl.expression = widen_Expression(decl.expression, new_block.members, wide);
				new_block.members[members_base] = new_decl;
				members_base += 1;
				fill_ptr.* = new_decl;
			case .RETURN;
				ret := cast(*Code_Return)it;
				blk := New(Code_Block);
				blk.block_type = .IMPERATIVE;
				blk.statements = NewArray(ret.arguments_sorted.count, *Code_Node);
				for arg, arg_index: ret.arguments_sorted
				{
					blk.statements[arg_index] = widen_Assign(xx new_block.statements[arg_index], arg, new_block.members, wide);
				}
				fill_ptr.* = blk;

			case;
				log("Cannot fill statement");
				fill_ptr.* = empty;
			}
		}


		ret := New(Code_Return);
		ret.kind = .RETURN;
		ret.arguments_sorted = NewArray(n_returns, *Code_Node);
		ret.arguments_unsorted = NewArray(n_returns, Code_Argument);
		for header.returns
		{
			id := New(Code_Ident);
			id.name = (cast(*Code_Declaration)new_block.statements[it_index]).name;
			id.resolved_declaration = cast(*Code_Declaration)new_block.statements[it_index];
			ret.arguments_sorted[it_index] = id;
			ret.arguments_unsorted[it_index].expression = id;
			ret.arguments_unsorted[it_index].name = null;
		}
		new_block.statements[new_block.statements.count - 1] = ret;

	}
	return new_header;
}



duplicate_Entry :: (ent : *Code_Scope_Entry) -> *Code_Scope_Entry, *Code_Scope_Entry
{
	first := New(Code_Scope_Entry);
	first.* = ent.*;
	first.name = sprint("%_0", ent.name);
	second := New(Code_Scope_Entry);
	second.* = ent.*;
	second.name = sprint("%_0", ent.name);
	return first, second;
}

type_Inst_To_Array :: (inst : *Code_Type_Instantiation, n : int) -> *Code_Type_Instantiation
{	
	if inst == null  return null;
	lit := New(Code_Literal);
	lit.kind = .LITERAL;
	lit.value_type = .NUMBER;
	lit._s64 = n;
	lit.value_flags |= .IS_A_NUMBER;

	ti := New(Code_Type_Instantiation);
	ti.array_element_type = inst;
	ti.array_dimension = lit;
	return ti;
}

widen_Expression :: (expr : *Code_Node, wide_vars : [] *Code_Scope_Entry, wide : int) -> *Code_Node
{
	arr := New(Code_Literal);
	arr.value_type = .ARRAY;
	arr.array_literal_info = New(Code_Array_Literal_Info);
	arr.array_literal_info.array_members = NewArray(wide, *Code_Node);
	for *arr.array_literal_info.array_members
	{
		it.* = substitute_Wide_Vars(expr, wide_vars, it_index);
	}

	return arr;
}

subscript :: (decl : *Code_Declaration, n : int) -> *Code_Node
{
	sub := New(Code_Binary_Operator);
	sub.kind = .BINARY_OPERATOR;
	sub.operator_type = xx Operator_Type.ARRAY_SUBSCRIPT;
	array := New(Code_Ident);
	array.name = decl.name;
	array.resolved_declaration = decl;
	sub.left = array;
	lit := New(Code_Literal);
	lit.value_type = .NUMBER;
	lit._s64 = n;
	sub.right = lit;
	return sub;
}

widen_Assign :: (assign_to : *Code_Declaration, expr : *Code_Node, wide_vars : [] *Code_Scope_Entry, wide : int) -> *Code_Node
{
	assert(assign_to.kind == .DECLARATION);
	assign_block := New(Code_Block);
	assign_block.block_type = .IMPERATIVE;
	assign_block.statements = NewArray(wide, *Code_Node);
	for assign_block.statements
	{
		ass := New(Code_Binary_Operator);
		ass.operator_type = #char "=";
		ass.left  = subscript(assign_to, it_index);
		ass.right = substitute_Wide_Vars(expr, wide_vars, it_index);
		assign_block.statements[it_index] = xx ass;
	}

	return assign_block;
}

substitute_Wide_Vars :: (expr : *Code_Node, wide_vars : [] *Code_Scope_Entry, index : int) -> *Code_Node
{
	recursive :: (expr : *Code_Node) -> *Code_Node #expand
	{
		return substitute_Wide_Vars(expr, wide_vars, index);
	}
	if expr.kind ==
	{
	case .BINARY_OPERATOR;
		binop := cast(*Code_Binary_Operator)expr;
		new_binop := New(Code_Binary_Operator);
		new_binop.* = binop;
		new_binop.left  = recursive(binop.left);
		new_binop.right = recursive(binop.right);
		return new_binop;
	case .LITERAL;
		return expr;
	case .IDENT;
		id := cast(*Code_Ident)expr;
		remap_to : *Code_Declaration;
		for wide_vars
		{
			if it.name == id.name 
			{
				remap_to = xx it;
				break;
			}
		}
		if remap_to
		{
			return subscript(remap_to, index);
		}else{
			log("Not remapping %", id.name);
			return expr;
		}
	case;
		log("%", expr.kind);
		return null;
	}
}


has_Note :: (decl : *Code_Procedure_Header, note : string) -> bool
{
	for decl.notes
	{
		if it.text == note  return true;
	}
	return false;
}

has_Note_Starting_With :: (decl : *Code_Procedure_Header, note : string) -> bool, string
{
	for decl.notes
	{
		if starts_with(it.text, note)  return true, it.text;
	}
	return false, "";
}

#import "Compiler";
#import "Basic";
#import "Atomics";
#import "Program_Print";
#import "String";
