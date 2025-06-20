"""init

Revision ID: c67e233b8aaf
Revises: 
Create Date: 2025-06-18 15:14:57.025147

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'c67e233b8aaf'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table('players_table', schema=None) as batch_op:
        batch_op.alter_column('is_ban',
               existing_type=sa.BOOLEAN(),
               nullable=False)
        batch_op.alter_column('is_allowed',
               existing_type=sa.BOOLEAN(),
               nullable=False)

    with op.batch_alter_table('teams_table', schema=None) as batch_op:
        batch_op.add_column(sa.Column('team_address', sa.String(length=100), nullable=False))
        batch_op.add_column(sa.Column('contact_number', sa.String(length=15), nullable=False))
        batch_op.drop_column('barangay_name')
        batch_op.drop_column('municipality_name')

    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table('teams_table', schema=None) as batch_op:
        batch_op.add_column(sa.Column('municipality_name', sa.VARCHAR(length=100), autoincrement=False, nullable=False))
        batch_op.add_column(sa.Column('barangay_name', sa.VARCHAR(length=100), autoincrement=False, nullable=False))
        batch_op.drop_column('contact_number')
        batch_op.drop_column('team_address')

    with op.batch_alter_table('players_table', schema=None) as batch_op:
        batch_op.alter_column('is_allowed',
               existing_type=sa.BOOLEAN(),
               nullable=True)
        batch_op.alter_column('is_ban',
               existing_type=sa.BOOLEAN(),
               nullable=True)

    # ### end Alembic commands ###
