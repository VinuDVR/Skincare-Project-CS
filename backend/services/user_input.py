def user_input():
    print("Skincare Recommendation Questionnaire.")

    skin_type = ["Normal", "Dry", "Oily", "Sensitive", "Combination"]
    print("How would you describe your skin type?")

    for i, option in enumerate(skin_type, 1):
        print(f"{i}. {option}")

    while True:
        try:
            skin_type_choice = int(input("Enter the number of your choice: "))
            if 1 <= skin_type_choice <= len(skin_type):
                user_skin_type = skin_type[skin_type_choice - 1]
                break
            else:
                print("Invalid choice.")
        except ValueError:
            print("Invalid input.")

    
    skin_concern_options = [
        "Acne or breakouts", "Redness or irritation", "Uneven skin tone", 
        "Fine lines or wrinkles", "Dark spots", "Large pores", 
        "Dullness", "Dehydration", "None of the above"]
    
    print("\nDo you experience any of the following skin concerns? (Select multiple by entering numbers separated by commas)")
    for i, option in enumerate(skin_concern_options, 1):
        print(f"{i}. {option}")
    while True:
        try:
            skin_concern_choices = input("Enter the numbers corresponding to your choices (e.g., 1,3,5): ")
            skin_concern_indices = [int(x.strip()) for x in skin_concern_choices.split(",")]
            if all(1 <= idx <= len(skin_concern_options) for idx in skin_concern_indices):
                user_skin_concerns = [skin_concern_options[idx - 1] for idx in skin_concern_indices]
                break
            else:
                print("Invalid choices.")
        except ValueError:
            print("Invalid input.")

    
    routine_options = ["Minimal (3 steps)", "Moderate (4 steps)", "Extensive (6 steps)"]
    print("\nHow much time do you prefer to spend on your skincare routine?")
    for i, option in enumerate(routine_options, 1):
        print(f"{i}. {option}")
    while True:
        try:
            routine_choice = int(input("Enter the number corresponding to your choice: "))
            if 1 <= routine_choice <= len(routine_options):
                user_routine_preference = routine_options[routine_choice - 1]
                break
            else:
                print("Invalid choice. Please choose a valid number.")
        except ValueError:
            print("Invalid input. Please enter a number.")

    
    price_range_options = ["Budget-Friendly", "Mid-range", "High-end"]
    print("\nDo you have a preferred product price range in mind?")
    for i, option in enumerate(price_range_options, 1):
        print(f"{i}. {option}")
    while True:
        try:
            price_range_choice = int(input("Enter the number corresponding to your choice: "))
            if 1 <= price_range_choice <= len(price_range_options):
                user_price_range = price_range_options[price_range_choice - 1]
                break
            else:
                print("Invalid choice. Please choose a valid number.")
        except ValueError:
            print("Invalid input. Please enter a number.")

    user_inputs = {
        "Skin Type": user_skin_type,
        "Skin Concerns": user_skin_concerns,
        "Routine Preference": user_routine_preference,
        "Price Range": user_price_range,
    }

    print("Inputs are as follows:")
    for key, value in user_inputs.items():
        print(f"{key}: {value}")

    return user_inputs

user_data = user_input()