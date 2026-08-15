using Seido.Utilities.SeedGenerator;

namespace Models;
public class Pet : IPet
{
    public virtual Guid PetId { get; set; }

    public virtual AnimalKind Kind { get; set; }
    public virtual AnimalMood Mood { get; set; }

    public virtual string Name { get; set; }

    // Model relationships
    // One Pet may have an owner Friend
    public virtual IFriend Friend { get; set; }


    #region constructors
    public Pet() { }
    public Pet(Pet org)
    {
        this.PetId = org.PetId;
        this.Kind = org.Kind;
        this.Name = org.Name;
    }
    #endregion
}


