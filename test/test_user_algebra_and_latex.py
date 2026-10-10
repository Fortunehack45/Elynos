import re

# Simulate MathFormulaProcessor.solveAlgebraicEquation logic in python to verify correctness
def solve_algebraic_equation(input_str):
    if '=' not in input_str:
        return None
    
    target_var = 'X'
    var_match = re.search(r'(?:value of|solve for|find|isolate)\s+([a-zA-Z])', input_str, re.IGNORECASE)
    if var_match:
        target_var = var_match.group(1)
        
    eq_match = re.search(r'([a-zA-Z0-9_\^\+\-\*/\(\)\.\s]+)=([a-zA-Z0-9_\^\+\-\*/\(\)\.\s]+)', input_str)
    if not eq_match:
        return None
        
    left = eq_match.group(1).strip()
    right = eq_match.group(2).strip().rstrip('?. ')
    
    v_pattern = re.compile(
        rf'^(\d+(?:\.\d+)?)\s*\*?\s*{re.escape(target_var)}$|^{re.escape(target_var)}\s*\*?\s*(\d+(?:\.\d+)?)$',
        re.IGNORECASE
    )
    
    side_match = v_pattern.match(right)
    target_on_right = True
    if not side_match:
        side_match = v_pattern.match(left)
        target_on_right = False
        
    if side_match:
        coeff_str = side_match.group(1) or side_match.group(2) or '1'
        coeff = float(coeff_str)
        expr_side = left if target_on_right else right
        clean_expr = re.sub(r'\s+', ' ', expr_side).strip()
        
        if coeff == 1.0:
            result_latex = f"{target_var} = {clean_expr}"
            text_result = f"{target_var} = {clean_expr}"
        else:
            coeff_disp = str(int(coeff)) if coeff.is_integer() else str(coeff)
            result_latex = f"{target_var} = \\frac{{{clean_expr}}}{{{coeff_disp}}}"
            text_result = f"{target_var} = ({clean_expr}) / {coeff_disp}"
            
        steps = [
            f"Given equation: {left} = {right}",
            f"Interpret product of coefficient {coeff_disp} and variable {target_var} ({coeff_disp} * {target_var})",
            f"Isolate {target_var} by dividing both sides by {coeff_disp}",
            f"Final result: {result_latex}"
        ]
        return {
            "target": target_var,
            "latex": result_latex,
            "text": text_result,
            "steps": steps
        }
    return None

# Test user query 1: "What is the value of X if x^2+y^2=X5"
res1 = solve_algebraic_equation("What is the value of X if x^2+y^2=X5")
print("TEST 1 - x^2+y^2=X5:")
assert res1 is not None, "Failed on x^2+y^2=X5"
print("  Target:", res1['target'])
print("  LaTeX:", res1['latex'])
print("  Text:", res1['text'])
assert "x^2 + y^2" in res1['latex'] or "x^2+y^2" in res1['latex'], "Expression mismatch"
assert "5" in res1['latex'], "Coefficient 5 mismatch"
print("  PASS!")

# Test user query 2: "Solve for X: x^2 + y^2 = 5X"
res2 = solve_algebraic_equation("Solve for X: x^2 + y^2 = 5X")
print("\nTEST 2 - 5X:")
assert res2 is not None
print("  LaTeX:", res2['latex'])
print("  PASS!")

# Test multi-turn follow up:
# Previous: "What is the value of X if x^2+y^2=X5"
# Current: "please the answer..."
prev = "What is the value of X if x^2+y^2=X5"
curr = "please the answer..."
effective = f"{prev} ({curr})"
res3 = solve_algebraic_equation(effective)
print("\nTEST 3 - Multi-Turn Follow-Up:")
assert res3 is not None
print("  LaTeX:", res3['latex'])
print("  PASS!")

print("\nALL ALGEBRA & MULTI-TURN CHECKS PASSED PERFECTLY!")
